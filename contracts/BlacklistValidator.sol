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

pragma solidity ^0.8.11;

import "./ownership/Claimable.sol";
import "./ownership/NoOwner.sol";
import "./ownership/CanReclaimToken.sol";
import "./IValidator.sol";

/**
 * @title BlacklistValidator
 * @dev Implements a validator which rejects transfers to blacklisted addresses.
 */
contract BlacklistValidator is IValidator, Claimable, CanReclaimToken, NoOwner {

    mapping (address => bool) public blacklist;

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

    /**
     * @dev Adds an address to the blacklist.
     * @param adversary Address to add.
     */
    function ban(address adversary) external onlyOwner {
        blacklist[adversary] = true;
        emit Ban(adversary);
    }

    /**
     * @dev Removes an address from the blacklist.
     * @param friend Address to remove.
     */
    function unban(address friend) external {
        blacklist[friend] = false;
        emit Unban(friend);
    }

    /**
     * @dev Validates token transfer.
     * Implements IValidator interface.
     */
    function validate(address from, address to, uint amount)
        external
        returns (bool valid)
    {
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
    function transferOwnership(address newOwner) public override(Claimable, Ownable){
      Claimable.transferOwnership(newOwner);
    }
}
