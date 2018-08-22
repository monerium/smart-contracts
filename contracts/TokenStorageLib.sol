pragma solidity ^0.4.24;

import "zeppelin-solidity/contracts/math/SafeMath.sol";

library TokenStorageLib {

    using SafeMath for uint;

    struct TokenStorage {
        mapping (address => uint) balances;
        mapping (address => mapping (address => uint)) allowed;
        uint totalSupply;
    }

    // INTERNAL
    function addBalance(TokenStorage storage self, address to, uint amount) 
        internal 
    {
        self.totalSupply = self.totalSupply.add(amount);
        self.balances[to] = self.balances[to].add(amount);
    }

    function subBalance(TokenStorage storage self, address from, uint amount) 
        internal 
    {
        self.totalSupply = self.totalSupply.sub(amount);
        self.balances[from] = self.balances[from].sub(amount);
    }

    function setAllowed(TokenStorage storage self, address owner, address spender, uint amount) 
        internal
    {
        self.allowed[owner][spender] = amount;
    }

    // INTERNAL CONSTANT
    function getSupply(TokenStorage storage self) 
        internal
        view 
        returns (uint) 
    {
        return self.totalSupply;
    }

    function getBalance(TokenStorage storage self, address who) 
        internal
        view 
        returns (uint) 
    {
        return self.balances[who];
    }

    function getAllowed(TokenStorage storage self, address owner, address spender) 
        internal
        view
        returns (uint) 
    {
        return self.allowed[owner][spender];
    }

}
