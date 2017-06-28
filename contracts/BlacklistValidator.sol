pragma solidity ^0.4.11;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Validator.sol";

contract BlacklistValidator is Validator, Ownable {

    mapping (address => bool) public blacklist;

    // EVENTS
    event Ban(address indexed adversary);
    event Unban(address indexed goodguy);

    // EXTERNAL
    function ban(address adversary) onlyOwner {
       blacklist[adversary] = true; 
       Ban(adversary);
    }

    function unban(address goodguy) onlyOwner {
        blacklist[goodguy] = false;
        Unban(goodguy);
    }

    // EXTERNAL CONSTANT
    function validate(address _from, address _to, uint _value) 
        constant
        returns (bool valid) 
    { 
        if (blacklist[_from]) {
            valid = false;
        } else {
            valid = true;
        }
        Decision(_from, _to, valid, _value);
    }

}
