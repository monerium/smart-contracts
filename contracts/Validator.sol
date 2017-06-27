pragma solidity ^0.4.10;

contract Validator {

    // params: 
    // _from
    // _to
    // _value
    // returns: valid
    function validate(address, address, uint) constant returns (bool) { }

    event Decision(address indexed from, address indexed to, bool valid, uint value);
}
