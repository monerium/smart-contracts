pragma solidity ^0.4.10;

import "./SmartController.sol";

contract TokenFrontend {
    SmartController controller;

    string public name;
    string public symbol;
    bytes3 public ticker;

    // constructor
    function TokenFrontend(string _name, string _symbol, bytes3 _ticker) {
        name = _name;
        symbol = _symbol;
        ticker = _ticker;
    }

    // external
    function setController(address _address) {
        controller = SmartController(_address);
        if (controller.ticker() != ticker) {
            throw;
        }
        controller.setFrontend(address(this));
    }

    function transfer(address to, uint value) returns (bool ok) {
        return controller.transfer(msg.sender, to, value);
    }

    function transferFrom(address from, address to, uint value) returns (bool ok) {
        return controller.transferFrom(msg.sender, from, to, value);
    }

    function approve(address spender, uint value) returns (bool ok) {
        return controller.approve(msg.sender, spender, value);
    }

    // external constant
    function getController() constant returns (address) {
        return address(controller);
    }

    function totalSupply() constant returns (uint) {
        return controller.totalSupply();
    }

    function balanceOf(address who) constant returns (uint) {
        return controller.balanceOf(who);
    }

    function allowance(address owner, address spender) constant returns (uint) {
        return controller.allowance(owner, spender);
    }

    function decimals() constant returns (uint) {
        return controller.decimals();
    }

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
