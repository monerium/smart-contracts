pragma solidity ^0.4.11;

import "zeppelin-solidity/contracts/SafeMathLib.sol";

library TokenStorageLib {
    using SafeMathLib for uint;

    struct TokenStorage {
        mapping (address => uint) balances;
        mapping (address => mapping (address => uint)) allowed;
        uint totalSupply;
    }

    // EXTERNAL
    function addBalance(TokenStorage storage self, address to, uint amount) {
        self.totalSupply = self.totalSupply.plus(amount);
        self.balances[to] = self.balances[to].plus(amount);
    }

    function subBalance(TokenStorage storage self, address from, uint amount) {
        self.totalSupply = self.totalSupply.minus(amount);
        self.balances[from] = self.balances[from].minus(amount);
    }

    function setAllowed(TokenStorage storage self, address owner, address spender, uint amount) {
        self.allowed[owner][spender] = amount;
    }

    // EXTERNAL CONSTANT
    function getSupply(TokenStorage storage self) constant returns (uint) {
        return self.totalSupply;
    }

    function getBalance(TokenStorage storage self, address who) constant returns (uint) {
        return self.balances[who];
    }

    function getAllowed(TokenStorage storage self, address owner, address spender) 
        constant
        returns (uint) 
    {
        return self.allowed[owner][spender];
    }
}
