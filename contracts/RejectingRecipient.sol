pragma solidity ^0.4.24;

import "./ITokenRecipient.sol";

contract RejectingRecipient is ITokenRecipient {

    function tokenFallback(address, uint256, bytes) external returns (bool) {
        revert();
        return false;
    }

}

