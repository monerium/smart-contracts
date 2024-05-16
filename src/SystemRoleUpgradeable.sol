// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

abstract contract SystemRoleUpgradeable is
    Ownable2StepUpgradeable,
    AccessControlUpgradeable
{
    bytes32 public constant SYSTEM_ROLE = keccak256("SYSTEM_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    function __SystemRole_init() internal initializer {
        __Ownable2Step_init();
        __Ownable_init(_msgSender());
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /**
     * @dev Emitted when system account is added.
     * @param account The address of the account.
     */
    event SystemAccountAdded(address indexed account);

    /**
     * @dev Emitted when system account is removed.
     * @param account The address of the account.
     */
    event SystemAccountRemoved(address indexed account);

    /**
     * @dev Emitted when admin account is added.
     * @param account The address of the account.
     */
    event AdminAccountAdded(address indexed account);

    /**
     * @dev Emitted when admin account is removed.
     * @param account The address of the account.
     */
    event AdminAccountRemoved(address indexed account);

    /**
     * @dev modifier to restrict access to admin accounts.
     */
    modifier onlyAdminAccounts() {
        require(
            hasRole(ADMIN_ROLE, _msgSender()),
            "SystemRole: caller is not an admin account"
        );
        _;
    }

    /**
     * @dev modifier to restrict access to system accounts.
     */
    modifier onlySystemAccounts() {
        require(
            hasRole(SYSTEM_ROLE, _msgSender()),
            "SystemRole: caller is not a system account"
        );
        _;
    }

    /**
     * @dev modifier to restrict access to admin account.
     */
    modifier onlyAdminAccount(address account) {
        require(
            hasRole(ADMIN_ROLE, account),
            "SystemRole: caller is not an admin account"
        );
        _;
    }

    /**
     * @dev modifier to restrict access to system account.
     */
    modifier onlySystemAccount(address account) {
        require(
            hasRole(SYSTEM_ROLE, account),
            "SystemRole: caller is not a system account"
        );
        _;
    }

    /**
     * @dev Checks wether an address is a system account.
     * @param account The address of the account.
     * @return true if system account.
     */
    function isSystemAccount(address account) public view returns (bool) {
        return hasRole(SYSTEM_ROLE, account);
    }

    /**
     * @dev Checks wether an address is a admin account.
     * @param account The address of the account.
     * @return true if admin account.
     */
    function isAdminAccount(address account) public view returns (bool) {
        return hasRole(ADMIN_ROLE, account);
    }

    /**
     * @dev add system account.
     * @param account The address of the account.
     */
    function addSystemAccount(address account) public virtual onlyOwner {
        grantRole(SYSTEM_ROLE, account);
        emit SystemAccountAdded(account);
    }

    /**
     * @dev remove system account.
     * @param account The address of the account.
     */
    function removeSystemAccount(address account) public virtual onlyOwner {
        revokeRole(SYSTEM_ROLE, account);
        emit SystemAccountRemoved(account);
    }

    /**
     * @dev add admin account.
     * @param account The address of the account.
     */
    function addAdminAccount(address account) public virtual onlyOwner {
        grantRole(ADMIN_ROLE, account);
        emit AdminAccountAdded(account);
    }

    /**
     * @dev remove admin account.
     * @param account The address of the account.
     */
    function removeAdminAccount(address account) public virtual onlyOwner {
        revokeRole(ADMIN_ROLE, account);
        emit AdminAccountRemoved(account);
    }

    // Override renounceOwnership to prevent renouncing ownership
    function renounceOwnership() public view override onlyOwner {
        revert("Ownership cannot be renounced");
    }
}
