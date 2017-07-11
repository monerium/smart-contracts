pragma solidity ^0.4.11;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./TokenStorageLib.sol";

contract TokenStorage is Ownable {
    using TokenStorageLib for TokenStorageLib.TokenStorage;

    TokenStorageLib.TokenStorage tokenStorage;

    // EXTERNAL
    function addBalance(address to, uint amount) onlyOwner {
        tokenStorage.addBalance(to, amount);
    }

    function subBalance(address from, uint amount) onlyOwner {
        tokenStorage.subBalance(from, amount);
    }

    function setAllowed(address owner, address spender, uint amount) onlyOwner {
        tokenStorage.setAllowed(owner, spender, amount);
    }

    // EXTERNAL CONSTANT
    function getSupply() constant returns (uint) {
        return tokenStorage.getSupply();
    }

    function getBalance(address who) constant returns (uint) {
        return tokenStorage.getBalance(who);
    }

    function getAllowed(address owner, address spender) constant returns (uint)
    {
        return tokenStorage.getAllowed(owner, spender);
    }
}
