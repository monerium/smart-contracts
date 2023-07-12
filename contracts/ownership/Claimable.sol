// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./Ownable.sol";

/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
abstract contract Claimable is Ownable {
    address public pendingOwner;
    
    /**
      * @dev emitted when the pendingOwner address is changed 
      * @param previousPendingOwner previous pendingOwner address
      * @param newPendingOwner new pendingOwner address
      */
      event OwnershipPendingChanged(address indexed previousPendingOwner, address indexed newPendingOwner);

    /**
     * @dev emitted when the pendingOwner address is changed
     * @param previousPendingOwner previous pendingOwner address
     * @param newPendingOwner new pendingOwner address
     */
    event OwnershipTransferPending(
        address indexed previousPendingOwner,
        address indexed newPendingOwner
    );

    /**
     * @dev Modifier throws if called by any account other than the pendingOwner.
     */
    modifier onlyPendingOwner() {
        require(msg.sender == pendingOwner);
        _;
    }

    /**
     * @dev Allows the current owner to set the pendingOwner address.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(
        address newOwner
    ) public virtual override onlyOwner {
<<<<<<< HEAD
        emit OwnershipTransferPending(pendingOwner, newOwner);
=======
        emit OwnershipPendingChanged(pendingOwner, newOwner);
>>>>>>> f2c706a (feat(Claimable): Adding new event for Pending state variable change)
        pendingOwner = newOwner;
    }

    /**
     * @dev Allows the pendingOwner address to finalize the transfer.
     */
    function claimOwnership() public onlyPendingOwner {
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}
