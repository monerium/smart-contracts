// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import "./IValidator.sol";

/**
 * @title Validator
 * @dev Role-based access control for transfer validation and account management.
 *      Uses OpenZeppelin AccessControl for secure role management.
 *      docs: https://docs.openzeppelin.com/contracts/4.x/api/access#AccessControl
 *      audit: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/audits/2023-05-v4.9.pdf
 */
contract Validator is AccessControl, IValidator {
    // Role identifiers
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant V1_BLOCKED_ROLE = keccak256("V1_BLOCKED_ROLE");
    bytes32 public constant BLACKLISTED_ROLE = keccak256("BLACKLISTED_ROLE");
    bytes32 public constant V1_FRONTEND_ROLE = keccak256("V1_FRONTEND_ROLE");

    // Contract identifier for interface compliance
    bytes32 private constant ID =
        0x5341d189213c4172d0c7256f80bc5f8e6350af3aaff7a029625d8dd94f0f82a5;

    /**
     * @dev Returns the contract identifier.
     */
    function CONTRACT_ID() public pure returns (bytes32) {
        return ID;
    }

    /**
     * @dev Sets up initial admin and role relationships.
     *      The deployer is the default admin.
     *      ADMIN_ROLE is the admin for blocked, blacklisted, and frontend roles.
     */
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(V1_BLOCKED_ROLE, ADMIN_ROLE);
        _setRoleAdmin(BLACKLISTED_ROLE, ADMIN_ROLE);
        _setRoleAdmin(V1_FRONTEND_ROLE, ADMIN_ROLE);
    }

    /**
     * @dev Validates a transfer between two accounts.
     *      - If called by a V1 frontend, checks if either account is blocked.
     *      - Always checks if either account is blacklisted.
     * @return valid True if transfer is allowed, false otherwise.
     */
    function validate(
        address from,
        address to,
        uint256 /* amount */
    ) external view override returns (bool valid) {
        if (isV1Frontend(msg.sender)) {
            valid = !(isV1Blocked(from) || isV1Blocked(to));
            if (!valid) {
                return false;
            }
        }
        if (isBlacklisted(from) || isBlacklisted(to)) {
            return false;
        }
        return true;
    }

    // --- Admin role management ---

    /**
     * @dev Grants ADMIN_ROLE to an account. Only callable by an admin.
     */
    function setAdmin(address account) external {
        grantRole(ADMIN_ROLE, account);
    }

    /**
     * @dev Revokes ADMIN_ROLE from an account. Only callable by an admin.
     */
    function revokeAdmin(address account) external {
        revokeRole(ADMIN_ROLE, account);
    }

    /**
     * @dev Checks if an account has ADMIN_ROLE.
     */
    function isAdminAccount(address account) public view returns (bool) {
        return hasRole(ADMIN_ROLE, account);
    }

    // --- Blocked role management ---

    /**
     * @dev Grants V1_BLOCKED_ROLE to an account. Only callable by an admin.
     */
    function setV1Blocked(address account) external {
        grantRole(V1_BLOCKED_ROLE, account);
    }

    /**
     * @dev Revokes V1_BLOCKED_ROLE from an account. Only callable by an admin.
     */
    function revokeV1Blocked(address account) external {
        revokeRole(V1_BLOCKED_ROLE, account);
    }

    /**
     * @dev Checks if an account has V1_BLOCKED_ROLE.
     */
    function isV1Blocked(address account) public view returns (bool) {
        return hasRole(V1_BLOCKED_ROLE, account);
    }

    // --- Blacklisted role management ---

    /**
     * @dev Grants BLACKLISTED_ROLE to an account. Only callable by an admin.
     */
    function setBlacklisted(address account) external {
        grantRole(BLACKLISTED_ROLE, account);
    }

    /**
     * @dev Revokes BLACKLISTED_ROLE from an account. Only callable by an admin.
     */
    function revokeBlacklisted(address account) external {
        revokeRole(BLACKLISTED_ROLE, account);
    }

    /**
     * @dev Checks if an account has BLACKLISTED_ROLE.
     */
    function isBlacklisted(address account) public view returns (bool) {
        return hasRole(BLACKLISTED_ROLE, account);
    }

    // --- Frontend role management ---

    /**
     * @dev Grants V1_FRONTEND_ROLE to an account. Only callable by an admin.
     */
    function setV1Frontend(address account) external {
        grantRole(V1_FRONTEND_ROLE, account);
    }

    /**
     * @dev Revokes V1_FRONTEND_ROLE from an account. Only callable by an admin.
     */
    function revokeV1Frontend(address account) external {
        revokeRole(V1_FRONTEND_ROLE, account);
    }

    /**
     * @dev Checks if an account has V1_FRONTEND_ROLE.
     */
    function isV1Frontend(address account) public view returns (bool) {
        return hasRole(V1_FRONTEND_ROLE, account);
    }
}
