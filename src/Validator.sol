// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import "./IValidator.sol";

// Interface to query ControllerToken for its frontend
interface IControllerToken {
    function getFrontend() external view returns (address);
}

/**
 * @title Validator
 * @dev Role-based access control for transfer validation and account management.
 *      Uses OpenZeppelin AccessControl for secure role management.
 *      Queries the caller (ControllerToken) to determine if the call originated from a V1 frontend.
 *      Gas optimized: skips V1 frontend check if no addresses are blocked.
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

    // Gas optimization: track number of V1_BLOCKED addresses
    // If zero, we can skip the expensive getFrontend() call
    uint256 private v1BlockedCount;

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
     *      - Gas optimized: only queries frontend if there are blocked addresses
     *      - Queries msg.sender (ControllerToken) to check if call is from V1 frontend
     *      - If from V1 frontend, checks if either account is blocked
     *      - Always checks if either account is blacklisted
     * @return valid True if transfer is allowed, false otherwise.
     */
    function validate(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool valid) {
        // Gas optimization: only check V1 frontend if there are any blocked addresses
        // On chains without V1 (Arbitrum, etc.), this saves gas by skipping getFrontend() call
        if (v1BlockedCount > 0) {
            // Try to query msg.sender to see if it's a ControllerToken with a frontend
            address frontend = address(0);
            try IControllerToken(msg.sender).getFrontend() returns (address _frontend) {
                frontend = _frontend;
            } catch {
                // Not a ControllerToken or getFrontend() failed
                // Treat as direct call (check msg.sender directly for backwards compatibility)
                frontend = msg.sender;
            }

            // If the call is from a V1 frontend, apply V1_BLOCKED checks
            if (isV1Frontend(frontend)) {
                if (isV1Blocked(from)) {
                    emit Decision(from, to, amount, false);
                    revert(
                        string(
                            abi.encodePacked(
                                "Transfer not supported:",
                                Strings.toHexString(from),
                                " is blocked in V1. Please use V2 instead. See https://monerium.dev/docs/tokens"
                            )
                        )
                    );
                }
                if (isV1Blocked(to)) {
                    emit Decision(from, to, amount, false);
                    revert(
                        string(
                            abi.encodePacked(
                                "Transfer not supported:",
                                Strings.toHexString(to),
                                " is blocked in V1. Please use V2 instead. See https://monerium.dev/docs/tokens"
                            )
                        )
                    );
                }
            }
        }

        // Always check blacklist regardless of call source
        if (isBlacklisted(from)) {
            emit Decision(from, to, amount, false);
            revert(
                string(
                    abi.encodePacked(
                        "Transfer not supported:",
                        Strings.toHexString(from),
                        " is blacklisted."
                    )
                )
            );
        }
        if (isBlacklisted(to)) {
            emit Decision(from, to, amount, false);
            revert(
                string(
                    abi.encodePacked(
                        "Transfer not supported:",
                        Strings.toHexString(to),
                        " is blacklisted."
                    )
                )
            );
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
     *      Increments the blocked count for gas optimization.
     */
    function setV1Blocked(address account) external {
        if (!hasRole(V1_BLOCKED_ROLE, account)) {
            v1BlockedCount++;
        }
        grantRole(V1_BLOCKED_ROLE, account);
    }

    /**
     * @dev Revokes V1_BLOCKED_ROLE from an account. Only callable by an admin.
     *      Decrements the blocked count for gas optimization.
     */
    function revokeV1Blocked(address account) external {
        if (hasRole(V1_BLOCKED_ROLE, account)) {
            v1BlockedCount--;
        }
        revokeRole(V1_BLOCKED_ROLE, account);
    }

    /**
     * @dev Checks if an account has V1_BLOCKED_ROLE.
     */
    function isV1Blocked(address account) public view returns (bool) {
        return hasRole(V1_BLOCKED_ROLE, account);
    }

    /**
     * @dev Returns the number of V1_BLOCKED addresses.
     *      Useful for monitoring and gas optimization checks.
     */
    function getV1BlockedCount() external view returns (uint256) {
        return v1BlockedCount;
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
