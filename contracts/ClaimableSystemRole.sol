// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./SystemRole.sol";

/**
 * @title ClaimableSystemRole
 * @dev Extension for the SystemRole contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
abstract contract ClaimableSystemRole is SystemRole {
    address public pendingOwner;

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
        emit OwnershipTransferPending(pendingOwner, newOwner);
        pendingOwner = newOwner;
    }

    /**
     * @dev Allows the pendingOwner address to finalize the transfer.
     */
    function claimOwnership() public onlyPendingOwner {
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        _setupRole(DEFAULT_ADMIN_ROLE, owner);
        pendingOwner = address(0);
    }
}
