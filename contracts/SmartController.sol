pragma solidity ^0.4.24;

import "./SmartTokenLib.sol";
import "./MintableController.sol";
import "./Validator.sol";

contract SmartController is MintableController {

    using SmartTokenLib for SmartTokenLib.SmartStorage;

    SmartTokenLib.SmartStorage smartToken;

    bytes3 public ticker;
    uint public decimals = 18;
    uint constant public INITIAL_SUPPLY = 0;

    // CONSTRUCTOR
    constructor(address _storage, address validator, bytes3 ticker_)
        public
        MintableController(_storage, INITIAL_SUPPLY) 
    {
        assert(validator != 0x0);
        smartToken.setValidator(validator);
        ticker = ticker_;
    }

    // EXTERNAL
    function setValidator(address validator) external {
        smartToken.setValidator(validator);
    }

    function recover(address from, address to, bytes32 h, uint8 v, bytes32 r, bytes32 s)
        external
        onlyOwner
        returns (bool)
    {
        return SmartTokenLib.recover(token, from, to, h, v, r, s);
    }

    // EXTERNAL ERC20
    function transfer(address to, uint value) external returns (bool ok) {
        return transfer_withCaller(msg.sender, to, value);
    }

    // PUBLIC ERC20 FRONT
    function transfer_withCaller(address _caller, address to, uint value) 
        public 
        returns (bool ok) 
    {
        if (!smartToken.validate(_caller, to, value)) {
            revert("transfer is not valid");
        }
        return super.transfer_withCaller(_caller, to, value);
    }

    // EXTERNAL CONSTANT
    function getValidator() external view returns (address) {
        return smartToken.getValidator();
    }

}
