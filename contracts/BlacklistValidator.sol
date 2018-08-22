pragma solidity ^0.4.24;

import "zeppelin-solidity/contracts/ownership/Claimable.sol";
import "zeppelin-solidity/contracts/ownership/NoOwner.sol";
import "./Validator.sol";

contract BlacklistValidator is Validator, Claimable, NoOwner {

    mapping (address => bool) public blacklist;

    // EVENTS
    event Ban(address indexed adversary);
    event Unban(address indexed friend);

    // EXTERNAL
    function ban(address adversary) external onlyOwner {
        blacklist[adversary] = true; 
        emit Ban(adversary);
    }

    function unban(address friend) external onlyOwner {
        blacklist[friend] = false;
        emit Unban(friend);
    }

    function validate(address from, address to, uint value) 
        external
        returns (bool valid) 
    { 
        if (blacklist[from]) {
            valid = false;
        } else {
            valid = true;
        }
        emit Decision(from, to, valid, value);
    }

}
