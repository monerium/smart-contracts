pragma solidity ^0.4.10;

import "./SmartToken.sol";

contract TokenController {
    SmartToken token;

    function TokenController(address _address) {
        token = SmartToken(_address);
    }

    function getToken() constant returns (address) {
        return address(token);
    }

    function setToken(address _address) {
        token = SmartToken(_address);
    }

    function totalSupply() constant returns (uint) {
        return token.totalSupply();
    }

    function balanceOf(address who) constant returns (uint) {
        return token.balanceOf(who);
    }

    function allowance(address owner, address spender) constant returns (uint) {
        return token.allowance(owner, spender);
    }

    function transfer(address to, uint value) returns (bool ok) {
        return token.transfer(to, value);
    }

    function transferFrom(address from, address to, uint value) returns (bool ok) {
        return token.transferFrom(from, to, value);
    }

    function approve(address spender, uint value) returns (bool ok) {
        return token.approve(spender, value);
    }

    // function name() constant returns (string) {
        // return string(token.name());
    // }

    function symbol() constant returns (bytes4) {
        return token.symbol();
    }

    function decimals() constant returns (uint) {
        return token.decimals();
    }

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
