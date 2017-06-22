pragma solidity ^0.4.4;

import "zeppelin-solidity/contracts/SafeMathLib.sol";
import "./TokenStorage.sol";

library ERC20Lib {
    using SafeMathLib for uint;

    // struct TokenStorage {
        // mapping (address => uint) balances;
        // mapping (address => mapping (address => uint)) allowed;
        // uint totalSupply;
    // }

    // external
    /*
    function init(TokenStorage db, address _caller, uint _initial_supply) {
        db.totalSupply = _initial_supply;
        db.balances[_caller] = _initial_supply;
    }

    function transfer(TokenStorage db, address _caller, address _to, uint _value) 
        returns (bool success) 
    {
        db.balances[_caller] = db.balances[_caller].minus(_value);
        db.balances[_to] = db.balances[_to].plus(_value);
        Transfer(_caller, _to, _value);
        return true;
    }

    function transferFrom(
        TokenStorage db, 
        address _caller, 
        address _from, 
        address _to, 
        uint _value
    ) returns (bool success) {
        var _allowance = db.allowed[_from][_caller];

        db.balances[_to] = db.balances[_to].plus(_value);
        db.balances[_from] = db.balances[_from].minus(_value);
        db.allowed[_from][_caller] = _allowance.minus(_value);
        Transfer(_from, _to, _value);
        return true;
    }
    */

    function balanceOf(TokenStorage db, address _owner) 
        constant 
        returns (uint balance) 
    {
        return db.getBalance(_owner);
    }

    /*
    function approve(TokenStorage db, address _caller, address _spender, uint _value) 
        constant
        returns (bool success) 
    {
        db.allowed[_caller][_spender] = _value;
        Approval(_caller, _spender, _value);
        return true;
    }

    function allowance(TokenStorage db, address _owner, address _spender) 
        constant 
        returns (uint remaining) 
    {
        return db.allowed[_owner][_spender];
    }
    */

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
