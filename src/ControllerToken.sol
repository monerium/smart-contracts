pragma solidity 0.8.20;

//SPDX-License-Identifier: APACHE-2.0

import "./Token.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";


interface IERC677Recipient {
    /**
     * @dev Receives notification from [ERC677] transferAndCall.
     * @param from Sender address.
     * @param amount Number of tokens.
     * @param data Additional data.
     */
    function onTokenTransfer(
        address from,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

contract ControllerToken is Token {
    struct ControllerTokenStorage {
        address frontend;
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

    using SignatureChecker for address;

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
        super.initialize(name, symbol, _validator);
        _getControllerStorage().ticker = _ticker;
    }

    modifier onlyFrontend() {
        require(
          isFrontend(msg.sender),
            "ControllerToken: caller is not the frontend"
        );
        _;
    }

    function isFrontend(address _address) public view returns (bool) {
        return _getControllerStorage().frontend == _address;
    }

    function getFrontend() public view returns (address) {
        return _getControllerStorage().frontend;
    }

    function ticker() public view returns (bytes3) {
        return _getControllerStorage().ticker;
    }

    function setFrontend(address _address) public {
        _getControllerStorage().frontend = _address;
    }

    function transfer_withCaller(
        address caller,
        address to,
        uint256 amount
    ) external onlyFrontend returns (bool) {
        _transfer(caller, to, amount);
        return true;
    }

    function transferFrom_withCaller(
        address caller,
        address from,
        address to,
        uint256 amount
    ) external onlyFrontend returns (bool) {
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
        address ,//from
        uint256 ,//amount
        bytes32 ,//h
        uint8 ,//v
        bytes32 ,//r
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

}

