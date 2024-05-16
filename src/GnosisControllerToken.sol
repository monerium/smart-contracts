pragma solidity 0.8.20;

//SPDX-License-Identifier: APACHE-2.0

import "./Token.sol";
import "./interfaces/IERC677Recipient.sol";

// The GnosisControllerToken contract acts as a bridge to ensure compatibility between the Smart-Contract v2 and the v1 TokenFrontend.
// It allows the v2's proxy to function as the controller for the v1 TokenFrontend.
// The ambition is to allow the v2's proxy to be the only contract that needs to be upgraded in the future.
contract GnosisControllerToken is Token {
    struct ControllerTokenStorage {
        bytes3 ticker;
    }

    bytes32 private constant ControllerStorageLocation =
        0xca4de6ad8795ef60887d43e50c5ce757428c24696bc0badb9e89cdef76bfe2c9;

    function _getControllerStorage()
        internal
        pure
        returns (ControllerTokenStorage storage $)
    {
        assembly {
            $.slot := ControllerStorageLocation
        }
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory name,
        string memory symbol,
        bytes3 _ticker,
        address _validator
    ) public initializer {
        ControllerTokenStorage storage $ = _getControllerStorage();
        super.initialize(name, symbol, _validator);
        $.ticker = _ticker;
    }

    modifier onlyFrontend() {
        require(
            isFrontend(msg.sender),
            "ControllerToken: caller is not the frontend"
        );
        _;
    }

    function isFrontend(address _address) public view returns (bool) {
        return (_address == getFrontend());
    }

    function getFrontend() public view returns (address) {
        bytes3 t = ticker();
        if (t == 0x455552) {
            // EUR
            return 0xcB444e90D8198415266c6a2724b7900fb12FC56E;
        } else if (t == 0x474250) {
            // GBP
            return 0x5Cb9073902F2035222B9749F8fB0c9BFe5527108;
        } else if (t == 0x555344) {
            // USD
            return 0x20E694659536C6B46e4B8BE8f6303fFCD8d1dF69;
        } else if (t == 0x49534b) {
            // ISK
            return 0xD8F84BF2E036A3c8E4c0e25ed2aAe0370F3CCca8;
        } else {
            revert("Unsupported ticker");
        }
    }

    function ticker() public view returns (bytes3) {
        return _getControllerStorage().ticker;
    }

    function transfer_withCaller(
        address caller,
        address to,
        uint256 amount
    ) external onlyFrontend returns (bool) {
        require(
            validator.validate(caller, to, amount),
            "Transfer not validated"
        );
        _transfer(caller, to, amount);
        return true;
    }

    function transferFrom_withCaller(
        address caller,
        address from,
        address to,
        uint256 amount
    ) external onlyFrontend returns (bool) {
        require(validator.validate(from, to, amount), "Transfer not validated");
        _spendAllowance(from, caller, amount);
        _transfer(from, to, amount);
        return true;
    }

    function approve_withCaller(
        address caller,
        address spender,
        uint256 amount
    ) external onlyFrontend returns (bool) {
        _approve(caller, spender, amount);
        return true;
    }

    function transferAndCall_withCaller(
        address caller,
        address to,
        uint256 amount,
        bytes calldata data
    ) external onlyFrontend returns (bool) {
        require(
            validator.validate(caller, to, amount),
            "Transfer not validated"
        );
        _transfer(caller, to, amount);
        IERC677Recipient recipient = IERC677Recipient(to);
        require(
            recipient.onTokenTransfer(caller, amount, data),
            "token handler returns false"
        );
        return true;
    }

    function mintTo_withCaller(
        address caller,
        address to,
        uint256 amount
    ) external onlyFrontend onlySystemAccount(caller) returns (bool) {
        _useMintAllowance(caller, amount);
        _mint(to, amount);

        return true;
    }

    function burnFrom_withCaller(
        address caller,
        address, //from
        uint256, //amount
        bytes32, //h
        uint8, //v
        bytes32, //r
        bytes32 //s
    ) external view onlyFrontend onlySystemAccount(caller) returns (bool) {
        revert("deprecated");
    }

    function recover_withCaller(
        address caller,
        address, //from
        address, //to
        bytes32, //h
        uint8, //v
        bytes32, //r
        bytes32 //s
    ) external view onlyFrontend onlySystemAccount(caller) returns (uint256) {
        revert("deprecated");
    }

    function claimOwnership() external onlyFrontend {
        acceptOwnership();
    }
}

