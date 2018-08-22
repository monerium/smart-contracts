pragma solidity ^0.4.24;

interface TokenRecipient { 

    function tokenFallback(address from, uint256 amount, bytes data) external; 

}


