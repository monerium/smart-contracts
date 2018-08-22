pragma solidity ^0.4.24;

import "./Validator.sol";
import "zeppelin-solidity/contracts/ownership/Claimable.sol";
import "zeppelin-solidity/contracts/ownership/NoOwner.sol";

contract ConstantValidator is Validator, Claimable, NoOwner {

    bool valid;

    // CONSTRUCTOR
    constructor(bool valid_) public {
        valid = valid_;
    }

    // EXTERNAL CONSTANT
    function validate(address, address, uint) external returns (bool) { 
        return valid;     
    }

}
