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

import "../ownership/Claimable.sol";
import "../ownership/NoOwner.sol";
import "../ownership/CanReclaimToken.sol";
import "../IValidator.sol";

/**
 * @title ConstantValidator
 * @dev Constantly validates token transfers based on the constructor value.
 */
contract ConstantValidator is IValidator, Claimable, CanReclaimToken, NoOwner {
    bool internal valid;

    /**
     * @dev Contract constructor.
     * @param valid_ Always return this value when validating.
     */
    constructor(bool valid_) {
        valid = valid_;
    }

    /**
     * @dev Validates token transfer.
     * Implements IValidator interface.
     */
    function validate(address, address, uint) external view returns (bool) {
        return valid;
    }

    /**
     * @dev Explicit override of transferOwnership from Claimable and Ownable
     * @param newOwner Address to transfer ownership to.
     */
    function transferOwnership(
        address newOwner
    ) public override(Claimable, Ownable) {
        Claimable.transferOwnership(newOwner);
    }
}
