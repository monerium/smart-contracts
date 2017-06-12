pragma solidity ^0.4.10;

import "./Validator.sol";

contract BlacklistValidator is Validator {

    mapping (address => bool) blacklist;

    function validate(address _from, address _to, uint _value) returns (bool valid) { 
        if (blacklist[_from]) {
            valid = false;
        } else {
            valid = true;
        }
        Decision(_from, _to, valid, _value);
    }

}
