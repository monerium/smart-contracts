pragma solidity ^0.4.24;

import "./TokenRecipient.sol";

contract AcceptingRecipient is TokenRecipient {

    address public from;
    uint256 public amount;
    bytes public data;

    function tokenFallback(address from_, uint256 amount_, bytes data_) external returns (bool) {
        from = from_;
        amount = amount_;
        data = data_;
        return true;
    }

}

