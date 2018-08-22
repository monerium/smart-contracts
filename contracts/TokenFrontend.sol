pragma solidity ^0.4.24;

import "./SmartController.sol";
import "zeppelin-solidity/contracts/ownership/Claimable.sol";
import "zeppelin-solidity/contracts/ownership/NoOwner.sol";

contract TokenFrontend is Claimable, NoOwner {

    SmartController controller;

    string public name;
    string public symbol;
    bytes3 public ticker;

    // EVENTS
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint amount, bytes data);

    // CONSTRUCTOR
    constructor(string name_, string symbol_, bytes3 ticker_, address controller_) internal {
        name = name_;
        symbol = symbol_;
        ticker = ticker_;
        setController(controller_);
    }

    // EXTERNAL
    function setController(address _address) public onlyOwner {
        assert(_address != 0x0);
        controller = SmartController(_address);
        assert(controller.ticker() == ticker);
    }

    function transfer(address to, uint value) external returns (bool ok) {
        ok = controller.transfer_withCaller(msg.sender, to, value);
        emit Transfer(msg.sender, to, value);
    }

    function transferFrom(address from, address to, uint value) external returns (bool ok) {
        ok = controller.transferFrom_withCaller(msg.sender, from, to, value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external returns (bool ok) {
        ok = controller.approve_withCaller(msg.sender, spender, value);
        emit Approval(msg.sender, spender, value);
    }

    function transferAndCall(address receiver, uint256 amount, bytes data) 
        external
        returns (bool ok) 
    {
        ok = controller.transferAndCall_withCaller(msg.sender, receiver, amount, data);
        emit Transfer(msg.sender, receiver, amount, data);
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
