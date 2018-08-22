pragma solidity ^0.4.24;

import "./TokenRecipient.sol";
import "./TokenStorage.sol";
import "./ERC20Lib.sol";

library ERC677Lib {

    using ERC20Lib for TokenStorage;

    // TODO: race condition
    function approveAndCall(
        TokenStorage db, 
        address caller, 
        address spender, 
        uint256 value, 
        bytes _extraData
    ) 
        external
        returns (bool success) 
    {
        if (db.approve(caller, spender, value)) {
            TokenRecipient recipient = TokenRecipient(spender);
            recipient.receiveApproval(caller, value, this, _extraData);
            return true;
        }
    }        

}