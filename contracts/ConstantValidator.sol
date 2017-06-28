pragma solidity ^0.4.11;

import "./Validator.sol";

contract ConstantValidator is Validator {

    bool valid;

    // CONSTRUCTOR
    function ConstantValidator(bool _valid) {
        valid = _valid;
    }

    // EXTERNAL CONSTANT
    function validate(address, address, uint) constant returns (bool) { 
        return valid;     
    }
}
