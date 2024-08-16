// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Token {
    function mint(address to, uint256 amount) external;
}

/**
 * @title BatchMint
 * @dev This contract is designed to facilitate the migration of balances from a legacy V1 token
 *      to a newly deployed V2 token contract. It enables batch minting of tokens to multiple
 *      recipients in a single transaction.
 */
contract BatchMint {
    
    /**
     * @dev Mints tokens to multiple recipients.
     * @param tokenAddress The address of the V2 token contract implementing the mint function.
     * @param recipients An array of recipient addresses to receive the minted tokens.
     * @param amounts An array of token amounts to be minted to each recipient. The length of this
     *        array must match the length of the recipients array.
     * 
     * Requirements:
     * - The caller must have the necessary mint allowance on the V2 token contract.
     * - The lengths of the recipients and amounts arrays must be equal.
     * - The contract must have sufficient gas to execute all minting operations.
     */
    function batchMint(address tokenAddress, address[] calldata recipients, uint256[] calldata amounts) external {
        require(recipients.length == amounts.length, "Recipients and amounts array length must match");
        
        Token token = Token(tokenAddress);
        
        for (uint256 i = 0; i < recipients.length; i++) {
            token.mint(recipients[i], amounts[i]);
        }
    }
}
