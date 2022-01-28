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
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Migrations is AccessControl /* Claimable */ {
  bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
  uint public last_completed_migration;

  /**
   * @dev Set initials roles.
   */
  constructor(){
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(OWNER_ROLE, msg.sender);
    _setRoleAdmin(OWNER_ROLE, OWNER_ROLE);
    //owner = msg.sender; // owner from depricated Inheritence
  }

  function setCompleted(uint completed) external /* onlyOwner */ { // onlyOwner from depricated Inheritence
    require(hasRole(OWNER_ROLE, msg.sender), "Caller is not an Owner");
    last_completed_migration = completed;
  }

  function upgrade(address new_address) external /* onlyOwner */ { // onlyOwner from depricated Inheritence
    require(hasRole(OWNER_ROLE, msg.sender), "Caller is not an Owner");
    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }

}
