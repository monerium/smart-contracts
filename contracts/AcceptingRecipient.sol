pragma solidity ^0.4.24;

import "./ITokenRecipient.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract AcceptingRecipient is ITokenRecipient, Ownable {

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

