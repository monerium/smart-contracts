pragma solidity ^0.4.24;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "./TokenStorage.sol";

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

library MintableTokenLib {

    using SafeMath for uint;

    event Mint(address indexed to, uint amount);
    event Burn(address indexed from, uint amount);
    event Transfer(address indexed from, address indexed to, uint value);

    /**
     * @dev Function to mint tokens
     * @param to The address that will recieve the minted tokens.
     * @param amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    // function mint(address to, uint amount) onlyOwner canMint returns (bool) {
    function mint(
        TokenStorage self, 
        address to, 
        uint amount
    ) 
        internal 
        returns (bool) 
    {
        self.addBalance(to, amount);
        emit Mint(to, amount);
        emit Transfer(0x0, to, amount);
        return true;
    }

    function burn(
        TokenStorage self, 
        address from, 
        uint amount
    ) 
        internal
        returns (bool) 
    {
        self.subBalance(from, amount);
        emit Burn(from, amount);
        return true;
    }

}