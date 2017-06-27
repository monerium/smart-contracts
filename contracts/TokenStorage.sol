pragma solidity ^0.4.11;

// import "zeppelin-solidity/contracts/SafeMathLib.sol";
// TODO: Ownership
import "TokenStorageLib.sol";

contract TokenStorage {
    using TokenStorageLib for TokenStorageLib.TokenStorage;

    TokenStorageLib.TokenStorage tokenStorage;

    function getSupply() constant returns (uint) {
        return tokenStorage.getSupply();
    }

    function getBalance(address who) constant returns (uint) {
        return tokenStorage.getBalance(who);
    }

    function addBalance(address to, uint amount) {
        tokenStorage.addBalance(to, amount);
    }

    function subBalance(address from, uint amount) {
        tokenStorage.subBalance(from, amount);
    }

    function setAllowed(address owner, address spender, uint amount) {
        tokenStorage.setAllowed(owner, spender, amount);
    }

    function getAllowed(address owner, address spender) 
        constant 
        returns (uint)
    {
        return tokenStorage.getAllowed(owner, spender);
    }
}
