pragma solidity ^0.4.10;

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

    // constructor
    function SmartController(address _frontend, address _storage, address _validator, bytes3 _ticker)
        MintableController(_frontend, _storage, INITIAL_SUPPLY) 
    {
        assert(_validator != 0x0);
        smartToken.setValidator(_validator);
        ticker = _ticker;
    }

    // external
    function getValidator() constant returns (address) {
        return smartToken.getValidator();
    }

    function setValidator(address _validator) {
        smartToken.setValidator(_validator);
    }

    function transfer(address to, uint value) returns (bool ok) {
        if (!smartToken.validate(msg.sender, to, value)) {
            throw;
        }
        return super.transfer(to, value);
    }
}
