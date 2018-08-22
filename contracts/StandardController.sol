pragma solidity ^0.4.24;


import "./TokenStorage.sol";
import "./ERC20Lib.sol";
// import "zeppelin-solidity/contracts/token/EternalTokenStorage.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * Standard ERC20 token
 *
 * https://github.com/ethereum/EIPs/issues/20
 */

contract StandardController is Ownable {
    using ERC20Lib for TokenStorage;

    TokenStorage token;
    address frontend;

    string public name;
    string public symbol;
    uint public decimals = 18;

    // MODIFIERS
    // either calling caller is sender or calling via frontend
    modifier guarded(address caller) {
        if (msg.sender == caller || msg.sender == frontend)
            _;
    }

    // EVENTS
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    // CONSTRUCTOR
    constructor(address _storage, uint initialSupply) public {
        assert(_storage == 0x0 || initialSupply == 0);
        if (_storage == 0x0) {
            token = new TokenStorage();
            token.addBalance(msg.sender, initialSupply);
        } else {
            token = TokenStorage(_storage);
        }
    }

    // EXTERNAL CONSTANT
    function getFrontend() external view returns (address) {
        return frontend;
    }

    function getStorage() external view returns (address) {
        return token;
    }

    // EXTERNAL
    function setFrontend(address _address) external onlyOwner { 
        frontend = _address;
    }

    // EXTERNAL ERC20
    function transfer(address to, uint value) 
        external 
        returns (bool ok) 
    {
        return transfer20(msg.sender, to, value);
    }

    function transferFrom(address from, address to, uint value) 
        external
        returns (bool ok) 
    {
        return transferFrom20(msg.sender, from, to, value);
    }

    function approve(address spender, uint value) 
        external
        returns (bool ok) 
    {
        return approve20(msg.sender, spender, value);
    }

    function approveAndCall(address spender, uint value, bytes extraData) 
        external
        returns (bool ok) 
    {
        return approveAndCall677(msg.sender, spender, value, extraData);
    }

    // PUBLIC ERC20 FRONT
    function transfer20(address _caller, address _to, uint _value) 
        public
        guarded(_caller)
        returns (bool ok) 
    {
        return token.transfer(_caller, _to, _value);
    }

    function transferFrom20(address _caller, address _from, address _to, uint _value) 
        public
        guarded(_caller)
        returns (bool ok) 
    {
        return token.transferFrom(_caller, _from, _to, _value);
    }

    function approve20(address _caller, address _spender, uint _value) 
        public
        guarded(_caller)
        returns (bool ok) 
    {
        return token.approve(_caller, _spender, _value);
    }

    // PUBLIC ERC677 FRONT
    function approveAndCall677(address _caller, address _spender, uint _value, bytes _extraData) 
        public
        guarded(_caller)
        returns (bool ok) 
    {
        return token.approveAndCall(_caller, _spender, _value, _extraData);
    }

    // EXTERNAL ERC20 CONSTANT
    function totalSupply() external view returns (uint) {
        return token.getSupply();
    }

    function balanceOf(address who) external view returns (uint) {
        return token.getBalance(who);
    }

    function allowance(address owner, address spender) external view returns (uint) {
        return token.allowance(owner, spender);
    }

}
