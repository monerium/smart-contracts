// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

/**
 * @title IValidator
 * @dev Contracts implementing this interface validate token transfers.
 */
interface IValidator {
    /**
     * @dev Emitted when a validator makes a decision.
     * @param from Sender address.
     * @param to Recipient address.
     * @param amount Number of tokens.
     * @param valid True if transfer approved, false if rejected.
     */
    event Decision(
        address indexed from,
        address indexed to,
        uint256 amount,
        bool valid
    );

    /**
     * @dev Validates token transfer.
     * If the sender is on the blacklist the transfer is denied.
     * @param from Sender address.
     * @param to Recipient address.
     * @param amount Number of tokens.
     */
    function validate(
        address from,
        address to,
        uint256 amount
    ) external returns (bool valid);

    /**
     * @dev Returns the contract identifier.
     */ 
     function CONTRACT_ID() external view returns (bytes32);

}
