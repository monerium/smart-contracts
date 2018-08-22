pragma solidity ^0.4.24;

import "./TokenRecipient.sol";

contract RejectingRecipient is TokenRecipient {

    function tokenFallback(address, uint256, bytes) external returns (bool) {
        revert();
        return false;
    }

}

