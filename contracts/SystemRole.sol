pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/access/rbac/Roles.sol";

/**
 * @title SystemRole
 * @dev SystemRole accounts have been approved to perform operational actions (e.g. mint and burn).
 * @notice addSystemAccount and removeSystemAccount are unprotected by default, i.e. anyone can call them.
 * @notice Contracts inheriting SystemRole *should* authorize the caller by overriding them.
 */
contract SystemRole {

    using Roles for Roles.Role;
    Roles.Role private _systemAccounts;

    /** 
     * @dev Emitted when system account is added.
     * @param account is a new system account.
     */
    event SystemAccountAdded(address indexed account);

    /** 
     * @dev Emitted when system account is removed.
     * @param account is the old system account.
     */
    event SystemAccountRemoved(address indexed account);

    /**
     * @dev Modifier which prevents non-system accounts from calling protected functions.
     */
    modifier onlySystemAccounts() {
        require(isSystemAccount(msg.sender));
        _;
    }

    /**
     * @dev System Role constructor.
     * @notice The contract is an abstract contract as a result of the internal modifier.
     */
    constructor() internal {}

    /**
     * @dev Checks whether an address is a system account.
     * @param account the address to check.
     * @return true if system account.
     */
    function isSystemAccount(address account) public view returns (bool) {
        return _systemAccounts.has(account);
    }

    /**
     * @dev Assigns the system role to an account.
     * @notice This method is unprotected and should be authorized in the child contract.
     */
    function addSystemAccount(address account) public {
        _systemAccounts.add(account);
        emit SystemAccountAdded(account);
    }

    /**
     * @dev Removes the system role from an account.
     * @notice This method is unprotected and should be authorized in the child contract.
     */
    function removeSystemAccount(address account) public {
        _systemAccounts.remove(account);
        emit SystemAccountRemoved(account);
    }

}
