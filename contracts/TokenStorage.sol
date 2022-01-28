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

/* import "openzeppelin-solidity/contracts/ownership/Claimable.sol"; */
/* import "openzeppelin-solidity/contracts/ownership/CanReclaimToken.sol"; */
/* import "openzeppelin-solidity/contracts/ownership/NoOwner.sol"; */

import "@openzeppelin/contracts/access/AccessControl.sol";

import "./TokenStorageLib.sol";

/**
 * @title TokenStorage
 * @dev External storage for tokens.
 * The storage is implemented in a separate contract to maintain state
 * between token upgrades.
 */
contract TokenStorage is AccessControl /*,Claimable, CanReclaimToken, NoOwner */ {
  bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
  using TokenStorageLib for TokenStorageLib.TokenStorage;

  TokenStorageLib.TokenStorage internal tokenStorage;

  /**
   * @dev Set initials roles.
   * Owners can revoke and grant themselves.
   */
  constructor(){
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(OWNER_ROLE, msg.sender);
    _setRoleAdmin(OWNER_ROLE, OWNER_ROLE);
  }

  /**
   * @dev Increases balance of an address.
   * @param to Address to increase.
   * @param amount Number of units to add.
   */
  function addBalance(address to, uint amount) external /* onlyOwner */ { //onlyOwner from depricated Inheritence
    require(hasRole(OWNER_ROLE, msg.sender), "caller is not an Owner");
    tokenStorage.addBalance(to, amount);
  }

  /**
   * @dev Decreases balance of an address.
   * @param from Address to decrease.
   * @param amount Number of units to subtract.
   */
  function subBalance(address from, uint amount) external /* onlyOwner */ { //onlyOwner from depricated Inheritence
    require(hasRole(OWNER_ROLE, msg.sender), "caller is not an Owner");
    tokenStorage.subBalance(from, amount);
  }

  /**
   * @dev Sets the allowance for a spender.
   * @param owner Address of the owner of the tokens to spend.
   * @param spender Address of the spender.
   * @param amount Qunatity of allowance.
   */
  function setAllowed(address owner, address spender, uint amount) external /* onlyOwner */ { //onlyOwner from depricated Inheritence
    require(hasRole(OWNER_ROLE, msg.sender), "caller is not an Owner");
    tokenStorage.setAllowed(owner, spender, amount);
  }

  /**
   * @dev Returns the supply of tokens.
   * @return Total supply.
   */
  function getSupply() external view returns (uint) {
    return tokenStorage.getSupply();
  }

  /**
   * @dev Returns the balance of an address.
   * @param who Address to lookup.
   * @return Number of units.
   */
  function getBalance(address who) external view returns (uint) {
    return tokenStorage.getBalance(who);
  }

  /**
   * @dev Returns the allowance for a spender.
   * @param owner Address of the owner of the tokens to spend.
   * @param spender Address of the spender.
   * @return Number of units.
   */
  function getAllowed(address owner, address spender)
    external
    view
    returns (uint)
  {
    return tokenStorage.getAllowed(owner, spender);
  }

}
