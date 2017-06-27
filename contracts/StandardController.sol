pragma solidity ^0.4.6;


import "./TokenFrontend.sol";
import "./TokenStorage.sol";
import "./ERC20Lib.sol";
// import "zeppelin-solidity/contracts/token/EternalTokenStorage.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * Standard ERC20 token
 *
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */

contract StandardController is Ownable {
    using ERC20Lib for TokenStorage;

    TokenStorage token;
    TokenFrontend frontend;

    string public name;
    string public symbol;
    uint public decimals = 18;

    modifier onlyFrontend() {
        if (msg.sender == address(frontend))
            _;
    }

    // either frontend or calling directly
    modifier isFront(address _caller) {
        if (msg.sender == address(frontend) || _caller == msg.sender)
            _;
    }

    // TODO: better solution?
    modifier ownerOrFrontend() {
        if (msg.sender == address(frontend) || tx.origin == owner)
            _;
    }

    // constructor
    // function StandardController(address _frontend, address _storage, uint initialSupply) {
    function StandardController(address _storage, uint initialSupply) {
        // frontend = TokenFrontend(_frontend);
        assert(_storage == 0x0 || initialSupply == 0);
        if (_storage == 0x0) {
            token = new TokenStorage();
            token.addBalance(msg.sender, initialSupply);
        } else {
            token = TokenStorage(_storage);
        }
        // transferOwnership(_frontend);
    }

    // external
    function getFrontend() constant returns (address) {
        return address(frontend);
    }

    // external constant
    function setFrontend(address _address) ownerOrFrontend { 
        frontend = TokenFrontend(_address);
        transferOwnership(_address);
    }

    // external erc20
    function transfer(address to, uint value) returns (bool ok) {
        return _transfer(msg.sender, to, value);
    }

    function transferFrom(address from, address to, uint value) 
        returns (bool ok) 
    {
        return _transferFrom(msg.sender, from, to, value);
    }

    function approve(address spender, uint value) 
        returns (bool ok) 
    {
        return _approve(msg.sender, spender, value);
    }

    // external erc20 front
    function _transfer(address _caller, address _to, uint _value) 
        isFront(_caller)
        returns (bool ok) 
    {
        return token.transfer(_caller, _to, _value);
    }

    function _transferFrom(address _caller, address _from, address _to, uint _value) 
        isFront(_caller)
        returns (bool ok) 
    {
        return token.transferFrom(_caller, _from, _to, _value);
    }

    function _approve(address _caller, address _spender, uint _value) 
        isFront(_caller)
        returns (bool ok) 
    {
        return token.approve(_caller, _spender, _value);
    }

    // external erc20 constant
    function totalSupply() constant returns (uint) {
        return token.getSupply();
    }

    function balanceOf(address who) constant returns (uint) {
        return token.getBalance(who);
    }

    function allowance(address owner, address spender) constant returns (uint) {
        return token.allowance(owner, spender);
    }

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
