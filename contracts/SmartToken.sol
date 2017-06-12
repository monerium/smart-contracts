pragma solidity ^0.4.10;

import "zeppelin-solidity/contracts/token/StandardToken.sol";
import "./SmartTokenLib.sol";
import "./Validator.sol";
// import "./BlacklistValidator.sol";

contract SmartToken is StandardToken {
    using SmartTokenLib for SmartTokenLib.SmartTokenStorage;

    SmartTokenLib.SmartTokenStorage smartToken;

    // string public name = "SmartToken";
    // string public symbol = "SMT";
    bytes4 public symbol;
    uint public decimals = 18;
    uint public INITIAL_SUPPLY = 10000000;

    function SmartToken(address _validator, string _name, bytes4 _symbol) {
        smartToken.setValidator(_validator);
        name = _name;
        symbol = _symbol;
        token.init(INITIAL_SUPPLY);
    }

    function transfer(address to, uint value) returns (bool ok) {
        if (!smartToken.validate(msg.sender, to, value)) {
            return false;
        }
        return StandardToken.transfer(to, value);
    }
}
