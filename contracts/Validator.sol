pragma solidity ^0.4.24;

interface Validator {

    // EVENTS
    event Decision(address indexed from, address indexed to, bool valid, uint value);

    function validate(address from, address to, uint value) external returns (bool valid);

}
