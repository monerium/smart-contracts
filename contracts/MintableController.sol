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

import "./StandardController.sol";
import "./MintableTokenLib.sol";

/**
 * @title MintableController
 * @dev This contracts implements functionality allowing for minting and burning of tokens.
 */
contract MintableController is StandardController {
    using MintableTokenLib for TokenStorage;

    /**
     * @dev Contract constructor.
     * @param storage_ Address of the token storage for the controller.
     * @param initialSupply The amount of tokens to mint upon creation.
     * @param frontend_ Address of the authorized frontend.
     */
    constructor(
        address storage_,
        uint initialSupply,
        address frontend_
    ) StandardController(storage_, initialSupply, frontend_) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @dev set maximum allowance for system accounts.
     * @param amount the Amount of allowance.
     */
    function setMaxMintAllowance(uint256 amount) public override onlyOwner {
        super.setMaxMintAllowance(amount);
    }

    /**
     * @dev Sets the allowance for a system account.
     * @param account The account to set the allowance for.
     * @param amount The amount to set the allowance to.
     */
    function setMintAllowance(
        address account,
        uint256 amount
    ) public override onlyAdminAccounts {
        super.setMintAllowance(account, amount);
    }

    /**
     * @dev Mints new tokens.
     * @param caller Address of the caller passed through the frontend.
     * @param to Address to credit the tokens.
     * @param amount Number of tokens to mint.
     */
    function mintTo_withCaller(
        address caller,
        address to,
        uint amount
    )
        public
        onlyFrontend
        onlyAllowedSystemAccount(caller, amount)
        returns (bool)
    {
        avoidBlackholes(to);
        mintAllowances[caller] = mintAllowances[caller] - amount;
        return token.mint(to, amount);
    }

    /**
     * @dev Burns tokens from token owner.
     * This removes the burned tokens from circulation.
     * @param caller Address of the caller passed through the frontend.
     * @param from Address of the token owner.
     * @param amount Number of tokens to burn.
     * @param h Hash which the token owner signed.
     * @param v Signature component.
     * @param r Signature component.
     * @param s Sigature component.
     */
    function burnFrom_withCaller(
        address caller,
        address from,
        uint amount,
        bytes32 h,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public onlyFrontend onlySystemAccount(caller) returns (bool) {
        return token.burn(from, amount, h, v, r, s);
    }

    /**
     * @dev Burns tokens from token owner.
     * This removes the burned tokens from circulation.
     * @param from Address of the token owner.
     * @param amount Number of tokens to burn.
     */
    function burnFrom(
        address from,
        uint amount
    ) public onlyFrontend onlySystemAccount(msg.sender) returns (bool) {
        return token.burn(from, amount);
    }
}
