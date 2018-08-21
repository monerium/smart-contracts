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
    modifier onlyFrontend() {
        if (msg.sender == frontend)
            _;
    }

    // either frontend or calling directly
    modifier isFront(address caller) {
        if (msg.sender == frontend || caller == msg.sender)
            _;
    }

    // TODO: better solution?
    modifier ownerOrFrontend() {
        if (msg.sender == frontend || tx.origin == owner)
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
    function setFrontend(address _address) external ownerOrFrontend { 
        frontend = _address;
    }

    // PUBLIC ERC20 FRONT
    function transfer(address caller, address _to, uint _value) 
        public
        isFront(caller)
        returns (bool ok) 
    {
        return token.transfer(caller, _to, _value);
    }

    function transferFrom(address caller, address _from, address _to, uint _value) 
        public
        isFront(caller)
        returns (bool ok) 
    {
        return token.transferFrom(caller, _from, _to, _value);
    }

    function approve(address caller, address _spender, uint _value) 
        public
        isFront(caller)
        returns (bool ok) 
    {
        return token.approve(caller, _spender, _value);
    }

    function approveAndCall(address caller, address _spender, uint _value, bytes _extraData) 
        public
        returns (bool ok) 
    {
        return token.approveAndCall(caller, _spender, _value, _extraData);
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
