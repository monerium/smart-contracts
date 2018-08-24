pragma solidity ^0.4.24;

/**
 * @title IValidator
 * @dev Contracts implementing this interface validate token transfers.
 */
interface IValidator {

    /**
     * @dev Emitted when a validator makes a decision.
     * @param from Sender address.
     * @param to Recipient address.
     * @param valid True if transfer approved, false if rejected.
     * @param amount The number of tokens.
     */
    event Decision(address indexed from, address indexed to, bool valid, uint amount);

    /**
     * @dev Validates token transfer.
     * If the sender is on the blacklist the transfer is denied.
     * @param from Sender address.
     * @param to Recipient address.
     * @param amount Number of tokens.
     */
    function validate(address from, address to, uint amount) external returns (bool valid);

}
