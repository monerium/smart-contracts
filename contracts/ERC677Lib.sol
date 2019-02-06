pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/AddressUtils.sol";
import "./ITokenRecipient.sol";
import "./TokenStorage.sol";
import "./ERC20Lib.sol";

/**
 * @title ERC677
 * @dev ERC677 token functionality.
 * https://github.com/ethereum/EIPs/issues/677
 */
library ERC677Lib {

    using ERC20Lib for TokenStorage;
    using AddressUtils for address;

    /**
     * @dev Transfers tokens and subsequently calls a method on the recipient [ERC677].
     * If the recipient is a non-contract address this method behaves just like transfer.
     * @notice db.transfer either returns true or reverts.
     * @param db Token storage to operate on.
     * @param caller Address of the caller passed through the frontend.
     * @param to Recipient address.
     * @param amount Number of tokens to transfer.
     * @param data Additional data passed to the recipient's tokenFallback method.
     */
    function transferAndCall(
        TokenStorage db, 
        address caller, 
        address to, 
        uint256 amount, 
        bytes data
    ) 
        external
        returns (bool) 
    {
        if (db.transfer(caller, to, amount)) {
            if (to.isContract()) {
                ITokenRecipient recipient = ITokenRecipient(to);
                recipient.tokenFallback(caller, amount, data);
            }
        }
        return true;
    }        

}
