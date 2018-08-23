pragma solidity ^0.4.24;


import "./TokenStorage.sol";
import "./ERC20Lib.sol";
import "./ERC677Lib.sol";
import "zeppelin-solidity/contracts/ownership/Claimable.sol";
import "zeppelin-solidity/contracts/ownership/CanReclaimToken.sol";
import "zeppelin-solidity/contracts/ownership/NoOwner.sol";
import "zeppelin-solidity/contracts/lifecycle/Destructible.sol";
import "zeppelin-solidity/contracts/lifecycle/Pausable.sol";

/**
 * Standard ERC20 token
 *
 * https://github.com/ethereum/EIPs/issues/20
 */

contract StandardController is Pausable, Destructible, Claimable, CanReclaimToken, NoOwner {

    using ERC20Lib for TokenStorage;
    using ERC677Lib for TokenStorage;

    TokenStorage token;
    address frontend;

    string public name;
    string public symbol;
    uint public decimals = 18;

    // MODIFIERS
    modifier guarded(address caller) {
        require(
            msg.sender == caller || msg.sender == frontend, 
            "either caller must be sender or calling via frontend"
        );
        _;
    }

    modifier avoidBlackholes(address to) {
        require(to != 0x0, "must not send to 0x0");
        require(to != address(this), "must not send to controller");
        require(to != address(token), "must not send to token storage");
        require(to != frontend, "must not send to frontend");
        _;
    }

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
        return address(token);
    }

    // EXTERNAL
    function setFrontend(address frontend_) external onlyOwner { 
        frontend = frontend_;
    }

    // EXTERNAL ERC20
    function transfer(address to, uint value) 
        external 
        returns (bool ok) 
    {
        return transfer_withCaller(msg.sender, to, value);
    }

    function transferFrom(address from, address to, uint value) 
        external
        returns (bool ok) 
    {
        return transferFrom_withCaller(msg.sender, from, to, value);
    }

    function approve(address spender, uint value) 
        external
        returns (bool ok) 
    {
        return approve_withCaller(msg.sender, spender, value);
    }

    // EXTERNAL ERC677
    function transferAndCall(
        address to, 
        uint256 amount, 
        bytes data
    ) 
        external
        returns (bool ok) 
    {
        return transferAndCall_withCaller(msg.sender, to, amount, data);
    }

    // PUBLIC ERC20 FRONT
    function transfer_withCaller(address caller, address to, uint value) 
        public
        guarded(caller)
        avoidBlackholes(to)
        whenNotPaused
        returns (bool ok) 
    {
        return token.transfer(caller, to, value);
    }

    function transferFrom_withCaller(address caller, address from, address to, uint value) 
        public
        guarded(caller)
        avoidBlackholes(to)
        whenNotPaused
        returns (bool ok) 
    {
        return token.transferFrom(caller, from, to, value);
    }

    function approve_withCaller(address caller, address spender, uint value) 
        public
        guarded(caller)
        whenNotPaused
        returns (bool ok) 
    {
        return token.approve(caller, spender, value);
    }

    // PUBLIC ERC677 FRONT
    function transferAndCall_withCaller(
        address caller, 
        address to, 
        uint256 amount, 
        bytes data
    ) 
        public
        guarded(caller)
        avoidBlackholes(to)
        whenNotPaused
        returns (bool ok) 
    {
        return token.transferAndCall(caller, to, amount, data);
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
