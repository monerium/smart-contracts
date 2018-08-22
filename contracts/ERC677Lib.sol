pragma solidity ^0.4.24;

import "zeppelin-solidity/contracts/AddressUtils.sol";
import "./TokenRecipient.sol";
import "./TokenStorage.sol";
import "./ERC20Lib.sol";

library ERC677Lib {

    using ERC20Lib for TokenStorage;
    using AddressUtils for address;

    // EVENTS
    event Transfer(address indexed from, address indexed to, uint amount, bytes data);

    function transferAndCall(
        TokenStorage db, 
        address caller, 
        address receiver, 
        uint256 amount, 
        bytes data
    ) 
        external
        returns (bool) 
    {
        if (db.transfer(caller, receiver, amount)) {
            emit Transfer(caller, receiver, amount, data);
            if (receiver.isContract()) {
                TokenRecipient recipient = TokenRecipient(receiver);
                recipient.tokenFallback(caller, amount, data);
            }
            return true;
        }
        return false;
    }        

}