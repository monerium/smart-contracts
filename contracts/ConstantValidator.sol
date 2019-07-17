pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/ownership/Claimable.sol";
import "openzeppelin-solidity/contracts/ownership/NoOwner.sol";
import "openzeppelin-solidity/contracts/ownership/CanReclaimToken.sol";
import "./IValidator.sol";

/** 
 * @title ConstantValidator
 * @dev Constantly validates token transfers based on the constructor value.
 */
contract ConstantValidator is IValidator, Claimable, CanReclaimToken, NoOwner {

    bool internal valid;

    /**
     * @dev Contract constructor.
     * @param valid_ Always return this value when validating.
     */
    constructor(bool valid_) public {
        valid = valid_;
    }

    /**
     * @dev Validates token transfer.
     * Implements IValidator interface.
     */
    function validate(address, address, uint) external returns (bool) { 
        return valid;     
    }

}
