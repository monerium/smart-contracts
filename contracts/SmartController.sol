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
        smartToken.setValidator(_validator);
        ticker = _ticker;
    }

    // external
    function transfer(address to, uint value) returns (bool ok) {
        if (!smartToken.validate(msg.sender, to, value)) {
            return false;
        }
        return StandardController.transfer(to, value);
    }
}
