pragma solidity 0.4.24;

/**
 * @title ITokenRecipient
 * @dev Contracts implementing this interface can participate in [ERC223 and ERC677].
 */
interface ITokenRecipient { 

    /**
     * @dev Receives notification from [ERC223 and ERC677] transferAndCall.
     * @param from Sender address.
     * @param amount Number of tokens.
     * @param data Additional data.
     */
    function tokenFallback(address from, uint256 amount, bytes data) external returns (bool); 

}


