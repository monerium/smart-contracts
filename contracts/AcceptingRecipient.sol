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

pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/ownership/CanReclaimToken.sol";
import "./IERC677Recipient.sol";

/**
 * @title AcceptingRecipient
 * @dev [ERC677]-compatible contract.
 * The contract accepts token ownership and stores data in public member variables.
 */
contract AcceptingRecipient is CanReclaimToken, IERC677Recipient {

    address public from;
    uint256 public amount;
    bytes public data;

    function onTokenTransfer(address from_, uint256 amount_, bytes data_) external returns (bool) {
        from = from_;
        amount = amount_;
        data = data_;
        return true;
    }

}

