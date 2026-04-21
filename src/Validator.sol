// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import "./IValidator.sol";

/**
 * @title Validator
 * @dev Role-based access control for transfer validation and account management.
 *      Uses OpenZeppelin AccessControl for secure role management.
 *      V1_BLOCKED_ROLE enforcement is handled by the ControllerToken._withCaller functions,
 *      which are the exclusive V1 entrypoints. This keeps the Validator chain-agnostic.
 *      docs: https://docs.openzeppelin.com/contracts/4.x/api/access#AccessControl
 *      audit: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/audits/2023-05-v4.9.pdf
 */
contract Validator is AccessControl, IValidator {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant V1_BLOCKED_ROLE = keccak256("V1_BLOCKED_ROLE");
    bytes32 public constant BLACKLISTED_ROLE = keccak256("BLACKLISTED_ROLE");

    bytes32 private constant ID =
        0x5341d189213c4172d0c7256f80bc5f8e6350af3aaff7a029625d8dd94f0f82a5;

    uint256 private v1BlockedCount;

    error Blacklisted(address account);
    error RenounceRoleNotAllowed();
    error UseValidatorRoleFunctions();

    function renounceRole(bytes32, address) public pure override {
        revert RenounceRoleNotAllowed();
    }

    function grantRole(bytes32 role, address account) public override {
        if (role == V1_BLOCKED_ROLE) revert UseValidatorRoleFunctions();
        super.grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public override {
        if (role == V1_BLOCKED_ROLE) revert UseValidatorRoleFunctions();
        super.revokeRole(role, account);
    }

    function CONTRACT_ID() external pure returns (bytes32) {
        return ID;
    }

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(V1_BLOCKED_ROLE, ADMIN_ROLE);
        _setRoleAdmin(BLACKLISTED_ROLE, ADMIN_ROLE);
    }

    function validate(
        address from,
        address to,
        uint256 /* amount */
    ) external override returns (bool valid) {
        _revertIfBlacklisted(from);
        _revertIfBlacklisted(to);
        return true;
    }

    function _revertIfBlacklisted(address account) internal view {
        if (hasRole(BLACKLISTED_ROLE, account)) revert Blacklisted(account);
    }

    // --- Admin role management ---

    function setAdmin(address account) external {
        grantRole(ADMIN_ROLE, account);
    }

    function revokeAdmin(address account) external {
        revokeRole(ADMIN_ROLE, account);
    }

    function isAdminAccount(address account) external view returns (bool) {
        return hasRole(ADMIN_ROLE, account);
    }

    // --- V1 Blocked role management ---

    function setV1Blocked(address account) external {
        _checkRole(ADMIN_ROLE);
        if (!hasRole(V1_BLOCKED_ROLE, account)) {
            v1BlockedCount++;
        }
        _grantRole(V1_BLOCKED_ROLE, account);
    }

    function revokeV1Blocked(address account) external {
        _checkRole(ADMIN_ROLE);
        if (hasRole(V1_BLOCKED_ROLE, account)) {
            v1BlockedCount--;
        }
        _revokeRole(V1_BLOCKED_ROLE, account);
    }

    function isV1Blocked(address account) public view returns (bool) {
        return hasRole(V1_BLOCKED_ROLE, account);
    }

    function getV1BlockedCount() external view returns (uint256) {
        return v1BlockedCount;
    }

    // --- Blacklisted role management ---

    function setBlacklisted(address account) external {
        grantRole(BLACKLISTED_ROLE, account);
    }

    function revokeBlacklisted(address account) external {
        revokeRole(BLACKLISTED_ROLE, account);
    }

    function isBlacklisted(address account) public view returns (bool) {
        return hasRole(BLACKLISTED_ROLE, account);
    }
}
