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

import "./TokenFrontend.sol";
import "./IPolygonPosChildToken.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title PolygonPosTokenFrontend
 * @notice This contract is to be deployed on Matic Polygon network.
 * @dev This contract implements a token forwarder.
 * The token frontend is [ERC20 and ERC677] compliant and forwards
 * standard methods to a controller. The primary function is to allow
 * for a statically deployed contract for users to interact with while
 * simultaneously allow the controllers to be upgraded when bugs are
 * discovered or new functionality needs to be added.
 * This token implement function for the Matic Polygon Brige.
 */
abstract contract PolygonPosTokenFrontend is TokenFrontend, IPolygonPosChildToken {
  bytes32 public constant DEPOSITOR_ROLE = keccak256("DEPOSITOR_ROLE");

  /**
   * @dev Contract constructor.
   * @notice The contract is an abstract contract as a result of the internal modifier.
   * @param name_ Token name.
   * @param symbol_ Token symbol.
   * @param ticker_ 3 letter currency ticker.
   * @param childChainManager_ Address of Polygon Pos's child chain manager proxy.
   */
  constructor(string memory name_, string memory symbol_, bytes3 ticker_,  address childChainManager_)
    TokenFrontend(name_, symbol_, ticker_)
    {
      _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
      _setupRole(DEPOSITOR_ROLE, childChainManager_);
    }

  /**
   * @notice Polygon Bridge Mechanism. Called when token is deposited on root chain
   * @dev Should be callable only by ChildChainManager
   * Should handle deposit by minting the required amount for user
   * @param user user address for whom deposit is being done
   * @param depositData abi encoded amount
   */
  function deposit(address user, bytes calldata depositData)
    override
    external
  {
    require(hasRole(DEPOSITOR_ROLE, msg.sender), "caller is not a DEPOSITOR");
    uint256 amount = abi.decode(depositData, (uint256));
    this.mintTo(user, amount);
  }

  /**
   * @notice Polygon Bridge Mechanism. Called when user wants to withdraw tokens back to root chain
   * @dev Should burn user's tokens. This transaction will be verified when exiting on root chain
   * @param amount amount of tokens to withdraw
   */
  function withdraw(uint256 amount)
    override
    external
  {
    controller.burnFrom(msg.sender, amount);
    emit Transfer(msg.sender, address(0x0), amount);
  }
}
