pragma solidity ^0.4.24;

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
    constructor(string _name, string _symbol, bytes3 _ticker, address _controller) internal {
        name = _name;
        symbol = _symbol;
        ticker = _ticker;
        setController(_controller);
    }

    // EXTERNAL
    function setController(address _address) public onlyOwner {
        assert(_address != 0x0);
        controller = SmartController(_address);
        assert(controller.ticker() == ticker);
        controller.setFrontend(address(this));
    }

    function transfer(address to, uint value) external returns (bool ok) {
        ok = controller.transfer(msg.sender, to, value);
        emit Transfer(msg.sender, to, value);
    }

    function transferFrom(address from, address to, uint value) external returns (bool ok) {
        return controller.transferFrom(msg.sender, from, to, value);
    }

    function approve(address spender, uint value) external returns (bool ok) {
        ok = controller.approve(msg.sender, spender, value);
        emit Approval(msg.sender, spender, value);
    }

    function approveAndCall(address spender, uint value, bytes extraData) external returns (bool ok) 
    {
        ok = controller.approveAndCall(msg.sender, spender, value, extraData);
        emit Approval(msg.sender, spender, value);
    }

    // EXTERNAL CONSTANT
    function getController() external view returns (address) {
        return address(controller);
    }

    function totalSupply() external view returns (uint) {
        return controller.totalSupply();
    }

    function balanceOf(address who) external view returns (uint) {
        return controller.balanceOf(who);
    }

    function allowance(address owner, address spender) external view returns (uint) {
        return controller.allowance(owner, spender);
    }

    function decimals() external view returns (uint) {
        return controller.decimals();
    }
}
