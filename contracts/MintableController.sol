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
import "./ITokenFrontend.sol";

/**
 * @title MintableController
 * @dev This contracts implements functionality allowing for minting and burning of tokens.
 */
contract MintableController is StandardController {
    using MintableTokenLib for TokenStorage;

    mapping(address => uint256) internal mintAllowances;
    uint256 internal maxMintAllowance;

    /**
     * @dev Contract constructor.
     * @param storage_ Address of the token storage for the controller.
     * @param initialSupply The amount of tokens to mint upon creation.
     * @param frontend_ Address of the authorized frontend.
     */
    constructor(
        address storage_,
        uint256 initialSupply,
        address frontend_
    ) StandardController(storage_, initialSupply, frontend_) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @dev Emitted when allowance is set.
     * @param account The address of the account.
     * @param amount The amount of allowance.
     */
    event MintAllowance(address indexed account, uint256 amount);

    /**
     * @dev Emitted when max allowance is set.
     * @param amount The amount of allowance.
     */
    event MaxMintAllowance(uint256 amount);

    /**
     * @dev modifier to restrict access to system accounts with enough allowance
     * @param account The address of the account.
     * @param amount The amount of allowance.
     */
    modifier onlyAllowedSystemAccount(address account, uint256 amount) {
        require(
            hasRole(SYSTEM_ROLE, account),
            "MintableController: caller is not a system account"
        );
        require(
            mintAllowances[account] >= amount,
            "MintableController: caller is not allowed to perform this action"
        );
        _;
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
        uint256 amount
    )
        public
        onlyFrontend
        onlyAllowedSystemAccount(caller, amount)
        returns (bool)
    {
        _avoidBlackholes(to);
        mintAllowances[caller] = mintAllowances[caller] - amount;
        require(token.mint(to, amount), "MintableController: mint failed");
        return true;
    }

    /**
     * @dev Burns tokens from token owner.
     * This removes the burned tokens from circulation.
     * @param caller Address of the caller passed through the frontend.
     */
    function burnFrom_withCaller(
        address caller,
        address,
        uint256,
        bytes32,
        uint8,
        bytes32,
        bytes32
    ) public view onlyFrontend returns (bool) {
        require(
            caller == address(this),
            "only allow this contract to be the caller"
        );
        return true;
    }

    /**
     * @dev Burns tokens from token owner.
     * This removes the burned tokens from circulation.
     * @param from Address of the token owner.
     * @param amount Number of tokens to burn.
     */
    function burnFrom(
        address from,
        uint256 amount,
        bytes32 h,
        bytes memory signature
    ) public onlySystemAccount(msg.sender) returns (bool) {
        require(
            token.burn(from, amount, h, signature),
            "MintableController: burn failed"
        );
        ITokenFrontend tokenFrontend = ITokenFrontend(frontend);
        require(
            tokenFrontend.burnFrom(from, amount, h, 0, 0, 0),
            "MintableController: TokenFrontend burn call failed"
        );
        return true;
    }

    /**
     * @dev set maximum allowance for system accounts.
     * @param amount The amount of allowance.
     */
    function setMaxMintAllowance(uint256 amount) public virtual onlyOwner {
        emit MaxMintAllowance(amount);
        maxMintAllowance = amount;
    }

    /**
     * @dev get maximum allowance for system accounts.
     * @return The amount of allowance.
     */
    function getMaxMintAllowance() public view virtual returns (uint256) {
        return maxMintAllowance;
    }

    /**
     * @dev set allowance for an account.
     * @param account The address of the account.
     * @param amount The amount of allowance.
     */
    function setMintAllowance(
        address account,
        uint256 amount
    ) public virtual onlyAdminAccounts {
        require(
            amount <= maxMintAllowance,
            "MintableController: allowance exceeds maximum setted by owner"
        );
        mintAllowances[account] = amount;
        emit MintAllowance(account, amount);
    }

    /**
     * @dev get allowance for an account.
     * @param account The address of the account.
     * @return The amount of allowance.
     */
    function getMintAllowance(
        address account
    ) public view virtual returns (uint256) {
        return mintAllowances[account];
    }
}
