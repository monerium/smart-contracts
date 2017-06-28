pragma solidity ^0.4.11;

import "./SmartController.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract TokenFrontend is Ownable {
    SmartController controller;

    string public name;
    string public symbol;
    bytes3 public ticker;

    // EVENTS
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    // CONSTRUCTOR
    function TokenFrontend(string _name, string _symbol, bytes3 _ticker, address _controller) {
        name = _name;
        symbol = _symbol;
        ticker = _ticker;
        setController(_controller);
    }

    // EXTERNAL
    function setController(address _address) onlyOwner {
        assert(_address != 0x0);
        controller = SmartController(_address);
        assert(controller.ticker() == ticker);
        controller.setFrontend(address(this));
    }

    function transfer(address to, uint value) returns (bool ok) {
        ok = controller._transfer(msg.sender, to, value);
        Transfer(msg.sender, to, value);
    }

    function transferFrom(address from, address to, uint value) returns (bool ok) {
        return controller._transferFrom(msg.sender, from, to, value);
    }

    function approve(address spender, uint value) returns (bool ok) {
        ok = controller._approve(msg.sender, spender, value);
        Approval(msg.sender, spender, value);
    }

    function approveAndCall(address spender, uint value, bytes extraData) returns (bool ok) 
    {
        ok = controller._approveAndCall(msg.sender, spender, value, extraData);
		Approval(msg.sender, spender, value);
    }

    // EXTERNAL CONSTANT
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
}
