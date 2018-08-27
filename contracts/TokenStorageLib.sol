pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

/** @title TokenStorageLib
 * @dev Implementation of an[external storage for tokens.
 */
library TokenStorageLib {

    using SafeMath for uint;

    struct TokenStorage {
        mapping (address => uint) balances;
        mapping (address => mapping (address => uint)) allowed;
        uint totalSupply;
    }

    /**
     * @dev Increases balance of an address.
     * @param self Token storage to operate on.
     * @param to Address to increase.
     * @param amount Number of units to add.
     */
    function addBalance(TokenStorage storage self, address to, uint amount) 
        internal 
    {
        self.totalSupply = self.totalSupply.add(amount);
        self.balances[to] = self.balances[to].add(amount);
    }

    /**
     * @dev Decreases balance of an address.
     * @param self Token storage to operate on.
     * @param from Address to decrease.
     * @param amount Number of units to subtract.
     */
    function subBalance(TokenStorage storage self, address from, uint amount) 
        internal 
    {
        self.totalSupply = self.totalSupply.sub(amount);
        self.balances[from] = self.balances[from].sub(amount);
    }

    /**
     * @dev Sets the allowance for a spender.
     * @param self Token storage to operate on.
     * @param owner Address of the owner of the tokens to spend.
     * @param spender Address of the spender.
     * @param amount Qunatity of allowance.
     */
    function setAllowed(TokenStorage storage self, address owner, address spender, uint amount) 
        internal
    {
        self.allowed[owner][spender] = amount;
    }

    /**
     * @dev Returns the supply of tokens.
     * @param self Token storage to operate on.
     * @return Total supply.
     */
    function getSupply(TokenStorage storage self) 
        internal
        view 
        returns (uint) 
    {
        return self.totalSupply;
    }

    /**
     * @dev Returns the balance of an address.
     * @param self Token storage to operate on.
     * @param who Address to lookup.
     * @return Number of units.
     */
    function getBalance(TokenStorage storage self, address who) 
        internal
        view 
        returns (uint) 
    {
        return self.balances[who];
    }

    /**
     * @dev Returns the allowance for a spender.
     * @param self Token storage to operate on.
     * @param owner Address of the owner of the tokens to spend.
     * @param spender Address of the spender.
     * @return Number of units.
     */
    function getAllowed(TokenStorage storage self, address owner, address spender) 
        internal
        view
        returns (uint) 
    {
        return self.allowed[owner][spender];
    }

}
