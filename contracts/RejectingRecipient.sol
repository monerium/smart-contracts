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

import "./ownership/CanReclaimToken.sol";
import "./IERC677Recipient.sol";

/**
 * @title RejectingRecipient
 * @dev [ERC677]-compatible contract.
 * The contract rejects token ownership.
 */
contract RejectingRecipient is CanReclaimToken, IERC677Recipient {

  function onTokenTransfer(address, uint256, bytes calldata) external pure returns (bool) {
    return false;
  }

}
