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

pragma solidity ^0.8.11;

import "./ClaimableSystemRole.sol";
import "./ownership/NoOwner.sol";
import "./ownership/CanReclaimToken.sol";
import "./IValidator.sol";

/**
 * @title BlacklistValidator
 * @dev Implements a validator which rejects transfers to blacklisted addresses.
 */
contract BlacklistValidator is
    IValidator,
    ClaimableSystemRole,
    CanReclaimToken,
    NoOwner
{
    mapping(address => bool) public blacklist;

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

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @dev Adds an address to the blacklist.
     * @param adversary Address to add.
     */
    function ban(address adversary) external {
        require(
            owner == msg.sender ||
                hasRole(SYSTEM_ROLE, msg.sender) ||
                hasRole(ADMIN_ROLE, msg.sender),
            "BlacklistValidator: must have admin role to ban"
        );

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
    function validate(
        address from,
        address to,
        uint amount
    ) external returns (bool valid) {
        if (blacklist[from]) {
            valid = false;
        } else {
            valid = true;
        }
        emit Decision(from, to, amount, valid);
    }

    /**
     * @dev Explicit override of transferOwnership from Claimable and Ownable
     * @param newOwner Address to transfer ownership to.
     */
    function transferOwnership(
        address newOwner
    ) public override(ClaimableSystemRole, Ownable) {
        ClaimableSystemRole.transferOwnership(newOwner);
    }

    /**
     * @dev Explicit override of addSystemAccount from ClaimableSystemRole
     * @param account Address to add as system account.
     */
    function addSystemAccount(address account) public override onlyOwner {
        super.addSystemAccount(account);
    }

    /**
     * @dev Explicit override of removeSystemAccount from ClaimableSystemRole
     * @param account Address to remove as system account.
     */
    function removeSystemAccount(address account) public override onlyOwner {
        super.removeSystemAccount(account);
    }

    /**
     * @dev Explicit override of addAdminAccount from ClaimableSystemRole
     * @param account Address to add as admin account.
     */
    function addAdminAccount(address account) public override onlyOwner {
        super.addAdminAccount(account);
    }

    /**
     * @dev Explicit override of removeAdminAccount from ClaimableSystemRole
     * @param account Address to remove as admin account.
     */
    function removeAdminAccount(address account) public override onlyOwner {
        super.removeAdminAccount(account);
    }
}
