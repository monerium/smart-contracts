pragma solidity ^0.4.24;

import "./IValidator.sol";
import "zeppelin-solidity/contracts/ownership/Claimable.sol";
import "zeppelin-solidity/contracts/ownership/NoOwner.sol";
import "zeppelin-solidity/contracts/ownership/CanReclaimToken.sol";

contract ConstantValidator is IValidator, Claimable, CanReclaimToken, NoOwner {

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
