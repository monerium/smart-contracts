pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/ownership/Claimable.sol";
import "openzeppelin-solidity/contracts/ownership/NoOwner.sol";
import "./IValidator.sol";

/**
 * @title BlacklistValidator
 * @dev Implements a validator which rejects transfers to blacklisted addresses.
 */
contract BlacklistValidator is IValidator, Claimable, CanReclaimToken, NoOwner {

    mapping (address => bool) public blacklist;

    /**
     * @dev Emitted when an address is added to the blacklist.
     * @param adversary Address added.
     */
    event Ban(address indexed adversary);

    /**
     * @dev Emitted when an address is removed from the blacklist.
     * @param friend Address removed.
     */
    event Unban(address indexed friend);

    /**
     * @dev Adds an address to the blacklist.
     * @param adversary Address to add.
     */
    function ban(address adversary) external onlyOwner {
        blacklist[adversary] = true; 
        emit Ban(adversary);
    }

    /**
     * @dev Removes an address from the blacklist.
     * @param friend Address to remove.
     */
    function unban(address friend) external onlyOwner {
        blacklist[friend] = false;
        emit Unban(friend);
    }

    /**
     * @dev Validates token transfer.
     * Implements IValidator interface.
     */
    function validate(address from, address to, uint amount) 
        external
        returns (bool valid) 
    { 
        if (blacklist[from]) {
            valid = false;
        } else {
            valid = true;
        }
        emit Decision(from, to, valid, amount);
    }

}
