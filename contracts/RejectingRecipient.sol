pragma solidity 0.4.24;

import "./ITokenRecipient.sol";

/**
 * @title RejectingRecipient
 * @dev [ERC677]-compatible contract.
 * The contract rejects token ownership.
 */
contract RejectingRecipient is ITokenRecipient {

    function tokenFallback(address, uint256, bytes) external returns (bool) {
        assert(false);
    }

}

