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

    // function setBalance
    // function getTokenStorage() constant returns (TokenStorage) {
        // return tokenStorage;
    // }
}
