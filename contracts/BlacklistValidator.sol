pragma solidity ^0.4.24;

import "zeppelin-solidity/contracts/ownership/Claimable.sol";
import "./Validator.sol";

contract BlacklistValidator is Validator, Claimable {

    mapping (address => bool) public blacklist;

    // EVENTS
    event Ban(address indexed adversary);
    event Unban(address indexed goodguy);

    // EXTERNAL
    function ban(address adversary) external onlyOwner {
        blacklist[adversary] = true; 
        emit Ban(adversary);
    }

    function unban(address goodguy) external onlyOwner {
        blacklist[goodguy] = false;
        emit Unban(goodguy);
    }

    // EXTERNAL CONSTANT
    function validate(address _from, address _to, uint _value) 
        external
        returns (bool valid) 
    { 
        if (blacklist[_from]) {
            valid = false;
        } else {
            valid = true;
        }
        emit Decision(_from, _to, valid, _value);
    }

}
