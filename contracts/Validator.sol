pragma solidity ^0.4.10;

contract Validator {
  event Decision(address indexed from, address indexed to, bool indexed valid, uint value);

  // params: 
  // _from
  // _to
  // _value
  // returns: valid
  function validate(address, address, uint) returns (bool) { }
}
