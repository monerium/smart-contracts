pragma solidity ^0.4.11;

import "./SmartTokenLib.sol";
import "./MintableController.sol";
import "./Validator.sol";

contract SmartController is MintableController {
    using SmartTokenLib for SmartTokenLib.SmartTokenStorage;
    using MintableTokenLib for SmartTokenLib.SmartTokenStorage;

    SmartTokenLib.SmartTokenStorage smartToken;

    bytes3 public ticker;
    uint public decimals = 18;
    uint public INITIAL_SUPPLY = 0;

    // CONSTRUCTOR
    function SmartController(address _storage, address _validator, bytes3 _ticker)
        MintableController(_storage, INITIAL_SUPPLY) 
    {
        assert(_validator != 0x0);
        smartToken.setValidator(_validator);
        ticker = _ticker;
    }

    // EXTERNAL
    function setValidator(address _validator) {
        smartToken.setValidator(_validator);
    }

    // EXTERNAL ERC20
    function transfer(address to, uint value) returns (bool ok) {
        return _transfer(msg.sender, to, value);
    }

    function _transfer(address _caller, address to, uint value) returns (bool ok) {
        if (!smartToken.validate(_caller, to, value)) {
            throw;
        }
        return super._transfer(_caller, to, value);
    }

    // EXTERNAL CONSTANT
    function getValidator() constant returns (address) {
        return smartToken.getValidator();
    }
}
