pragma solidity ^0.4.6;


import "./TokenFrontend.sol";
import "zeppelin-solidity/contracts/token/ERC20Lib.sol";
import "zeppelin-solidity/contracts/token/EternalTokenStorage.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * Standard ERC20 token
 *
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */

contract StandardController is Ownable {
    using ERC20Lib for EternalTokenStorage.TokenStorage;

    EternalTokenStorage.TokenStorage token;
    TokenFrontend frontend;

    string public name;
    string public symbol;
    uint public decimals = 18;
    uint public INITIAL_SUPPLY = 10000;

    // constructor
    function StandardController(address _frontend) {
        frontend = TokenFrontend(_frontend);
        token.init(msg.sender, INITIAL_SUPPLY);
        transferOwnership(_frontend);
    }

    // external
    function getFrontend() returns (address) {
        return address(frontend);
    }

    function setFrontend(address _address) onlyOwner {
        frontend = TokenFrontend(_address);
    }

    function transfer(address _caller, address to, uint value) returns (bool ok) {
        return token.transfer(_caller, to, value);
    }

    function transferFrom(address _caller, address from, address to, uint value) 
        returns (bool ok) 
    {
        return token.transferFrom(_caller, from, to, value);
    }

    function approve(address _caller, address spender, uint value) returns (bool ok) {
        return token.approve(_caller, spender, value);
    }

    // external constant
    function totalSupply() constant returns (uint) {
        return token.totalSupply;
    }

    function balanceOf(address who) constant returns (uint) {
        return token.balanceOf(who);
    }

    function allowance(address owner, address spender) constant returns (uint) {
        return token.allowance(owner, spender);
    }

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
