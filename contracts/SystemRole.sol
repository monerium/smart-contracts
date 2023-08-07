/* SPDX-License-Identifier: apache-2.0 */
/**
 * Copyright 2022 Monerium ehf.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ownership/Ownable.sol";

/**
 * @title SystemRole
 * @dev SystemRole accounts have been approved to perform operational actions (e.g. mint and burn).
 * @dev AdminRole accounts have been approved to perform administrative actions (e.g. setting allowances).
 * @notice The contract is an abstract contract.
 */
abstract contract SystemRole is AccessControl, Ownable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant SYSTEM_ROLE = keccak256("SYSTEM_ROLE");

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
     * @dev modifier to restrict access to system accounts.
     */
    modifier onlySystemAccounts() {
        require(
            hasRole(SYSTEM_ROLE, msg.sender),
            "SystemRole: caller is not a system account"
        );
        _;
    }

    /**
     * @dev modifier to restrict access to system accounts.
     * @param account The address of the account.
     */
    modifier onlySystemAccount(address account) {
        require(
            hasRole(SYSTEM_ROLE, account),
            "SystemRole: caller is not a system account"
        );
        _;
    }

    /**
     * @dev modifier to restrict access to admin accounts.
     */
    modifier onlyAdminAccounts() {
        require(
            hasRole(ADMIN_ROLE, msg.sender),
            "SystemRole: caller is not an admin account"
        );
        _;
    }

    /**
     * @dev modifier to restrict access to admin accounts.
     * @param account The address of the account.
     */
    modifier onlyAdminAccount(address account) {
        require(
            hasRole(ADMIN_ROLE, account),
            "SystemRole: caller is not an admin account"
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
}
