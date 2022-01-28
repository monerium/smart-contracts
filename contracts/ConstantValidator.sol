/* SPDX-License-Identifier: apache-2.0 */
/**
 * Copyright 2019 Monerium ehf.
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

//import "openzeppelin-solidity/contracts/ownership/Claimable.sol";
//import "openzeppelin-solidity/contracts/ownership/NoOwner.sol";
//import "openzeppelin-solidity/contracts/ownership/CanReclaimToken.sol";
import "./IValidator.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title ConstantValidator
 * @dev Constantly validates token transfers based on the constructor value.
 */
contract ConstantValidator is IValidator, AccessControl /* Claimable, CanReclaimToken, NoOwner*/ {
  bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bool internal valid;

    /**
     * @dev Contract constructor.
     * Set initials roles.
     * @param valid_ Always return this value when validating.
     */
    constructor(bool valid_) {
        valid = valid_;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(OWNER_ROLE, msg.sender);
        _setRoleAdmin(OWNER_ROLE, OWNER_ROLE);
    }

    /**
     * @dev Validates token transfer.
     * Implements IValidator interface.
     */
    function validate(address, address, uint) external view returns (bool) {
        return valid;
    }

}
