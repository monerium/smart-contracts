pragma solidity ^0.4.10;

// import "zeppelin-solidity/contracts/token/StandardToken.sol";
import "./StandardController.sol";
import "./SmartTokenLib.sol";
import "./Validator.sol";

contract SmartController is StandardController {
    using SmartTokenLib for SmartTokenLib.SmartTokenStorage;

    SmartTokenLib.SmartTokenStorage smartToken;

    bytes3 public ticker;
    uint public decimals = 18;
    uint public INITIAL_SUPPLY = 10000000;

    // constructor
    function SmartController(address _frontend, address _validator, bytes3 _ticker)                 
        StandardController(_frontend) 
    {
        smartToken.setValidator(_validator);
        ticker = _ticker;
    }

    // external
    function transfer(address _caller, address to, uint value) returns (bool ok) {
        if (!smartToken.validate(_caller, to, value)) {
            return false;
        }
        return StandardController.transfer(_caller, to, value);
    }
}
