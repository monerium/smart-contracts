// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

/// @title SwapV1V2 (on-chain 1:1 venue)
/// @notice Pulls tokenIn, pushes tokenOut same amount; supports optional permit; no reserves.
contract SwapV1V2 is Initializable, OwnableUpgradeable, UUPSUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20 for IERC20;

    address public V1;
    address public V2;

    event Swapped(
        address indexed caller,
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        address to
    );

    error BadPair();
    error ZeroAmount();

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address v1, address v2, address initialOwner) public initializer {
        require(
            v1 != address(0) && v2 != address(0) && v1 != v2,
            "bad address"
        );
        V1 = v1;
        V2 = v2;
        
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    /// @dev Exact-in, 1:1 out. Keep minOut for aggregators; always amountOut == amountIn.
    function swapExactIn(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minOut,
        address to
    ) external nonReentrant returns (uint256 amountOut) {
        _checkPair(tokenIn, tokenOut);
        if (amountIn == 0) revert ZeroAmount();
        require(amountIn >= minOut, "slip");

        // if the caller is also the recipient, skip the transferFrom/transfer
        if (msg.sender != to) {
            IERC20(tokenIn).safeTransferFrom(
                msg.sender,
                address(this),
                amountIn
            );
            IERC20(tokenOut).safeTransfer(to, amountIn);
        }

        emit Swapped(msg.sender, tokenIn, tokenOut, amountIn, to);
        return amountIn;
    }

    /// @dev Same as swapExactIn but first requires ERC-2612 permit on tokenIn.
    function swapWithPermitStrict(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minOut,
        address to,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant returns (uint256 amountOut) {
        _checkPair(tokenIn, tokenOut);
        if (amountIn == 0) revert ZeroAmount();
        require(amountIn >= minOut, "slip");

        // if the caller is also the recipient, skip the transferFrom/transfer
        if (msg.sender != to) {
            IERC20Permit(tokenIn).permit(
                msg.sender,
                address(this),
                amountIn,
                deadline,
                v,
                r,
                s
            );
            IERC20(tokenIn).safeTransferFrom(
                msg.sender,
                address(this),
                amountIn
            );
            IERC20(tokenOut).safeTransfer(to, amountIn);
        }

        emit Swapped(msg.sender, tokenIn, tokenOut, amountIn, to);
        return amountIn;
    }

    /// @dev Best-effort permit: tries permit, ignores failure. Useful when tokenIn may not support 2612.
    function swapWithPermitBestEffort(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minOut,
        address to,
        bytes calldata permitCalldata // abi.encode(deadline, v, r, s) or empty
    ) external nonReentrant returns (uint256 amountOut) {
        _checkPair(tokenIn, tokenOut);
        if (amountIn == 0) revert ZeroAmount();
        require(amountIn >= minOut, "slip");

        // if the caller is also the recipient, skip the transferFrom/transfer
        if (msg.sender != to) {
            if (permitCalldata.length == 97) {
                // Manually decode packed data: 32 bytes deadline + 1 byte v + 32 bytes r + 32 bytes s
                uint256 deadline = uint256(bytes32(permitCalldata[0:32]));
                uint8 v = uint8(permitCalldata[32]);
                bytes32 r = bytes32(permitCalldata[33:65]);
                bytes32 s = bytes32(permitCalldata[65:97]);
                // low-level call so non-2612 tokens don't revert the whole tx
                // solhint-disable-next-line avoid-low-level-calls
                (bool success, ) = tokenIn.call(
                    abi.encodeWithSelector(
                        IERC20Permit.permit.selector,
                        msg.sender,
                        address(this),
                        amountIn,
                        deadline,
                        v,
                        r,
                        s
                    )
                );
                // Intentionally ignore success - this is best effort
                success; // Acknowledge the variable to avoid unused variable warning
            }

            IERC20(tokenIn).safeTransferFrom(
                msg.sender,
                address(this),
                amountIn
            );
            IERC20(tokenOut).safeTransfer(to, amountIn);
        }
        
        emit Swapped(msg.sender, tokenIn, tokenOut, amountIn, to);
        return amountIn;
    }

    /// @notice Deterministic quote for pathfinders, returns amountIn on valid pair, else 0.
    function quote(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external view returns (uint256) {
        return _isPair(tokenIn, tokenOut) ? amountIn : 0;
    }

    function _checkPair(address a, address b) internal view {
        if (!_isPair(a, b)) revert BadPair();
    }

    function _isPair(address a, address b) internal view returns (bool) {
        return (a == V1 && b == V2) || (a == V2 && b == V1);
    }
}
