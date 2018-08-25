pragma solidity ^0.4.24;

import "zeppelin-solidity/contracts/ownership/Claimable.sol";
import "zeppelin-solidity/contracts/ownership/CanReclaimToken.sol";
import "zeppelin-solidity/contracts/ownership/NoOwner.sol";
import "./SmartController.sol";

/**
 * @title TokenFrontend
 * @dev This contract implements a token forwarder.
 * The token frontend is [ERC20 and ERC677] compliant and forwards
 * standard methods to a controller. The primary function is to allow
 * for a statically deployed contract for users to interact with while
 * simultaneously allow the controllers to be upgraded when bugs are
 * discovered or new functionality needs to be added.
 */
contract TokenFrontend is Claimable, CanReclaimToken, NoOwner {

    SmartController controller;

    string public name;
    string public symbol;
    bytes3 public ticker;

    /**
     * @dev Emitted when tokens are transferred.
     * @param from Sender address.
     * @param to Recipient address.
     * @param amount Number of tokens transferred.
     */
    event Transfer(address indexed from, address indexed to, uint amount);

    /**
     * @dev Emitted when tokens are transferred.
     * @param from Sender address.
     * @param to Recipient address.
     * @param amount Number of tokens transferred.
     * @param data Additional data passed to the recipient's tokenFallback method.
     */
    event Transfer(address indexed from, address indexed to, uint amount, bytes data);

    /**
     * @dev Emitted when spender is granted an allowance.
     * @param owner Address of the owner of the tokens to spend.
     * @param spender The address of the future spender.
     * @param amount The allowance of the spender.
     */
    event Approval(address indexed owner, address indexed spender, uint amount);

    /**
     * @dev Contract constructor.
     * @param name_ Token name.
     * @param symbol_ Token symbol.
     * @param ticker_ 3 letter currency ticker.
     */
    constructor(string name_, string symbol_, bytes3 ticker_, address controller_) internal {
        name = name_;
        symbol = symbol_;
        ticker = ticker_;
        setController(controller_);
    }

    /**
     * @dev Sets a new controller.
     * @param address_ Address of the controller.
     */
    function setController(address address_) public onlyOwner {
        assert(address_ != 0x0);
        controller = SmartController(address_);
        assert(controller.ticker() == ticker);
    }

    /**
     * @dev Transfers tokens [ERC20]. 
     * @param to Recipient address.
     * @param amount Number of tokens to transfer.
     */
    function transfer(address to, uint amount) external returns (bool ok) {
        ok = controller.transfer_withCaller(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
    }

    /**
     * @dev Transfers tokens from a specific address [ERC20].
     * The address owner has to approve the spender beforehand.
     * @param from Address to debet the tokens from.
     * @param to Recipient address.
     * @param amount Number of tokens to transfer.
     */
    function transferFrom(address from, address to, uint amount) external returns (bool ok) {
        ok = controller.transferFrom_withCaller(msg.sender, from, to, amount);
        emit Transfer(from, to, amount);
    }

    /**
     * @dev Approves a spender [ERC20].
     * Note that using the approve/transferFrom presents a possible
     * security vulnerability described in:
     * https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/edit#heading=h.quou09mcbpzw
     * Use transferAndCall to mitigate.
     * @param spender The address of the future spender.
     * @param amount The allowance of the spender.
     */
    function approve(address spender, uint amount) external returns (bool ok) {
        ok = controller.approve_withCaller(msg.sender, spender, amount);
        emit Approval(msg.sender, spender, amount);
    }

    /**
     * @dev Transfers tokens and subsequently calls a method on the recipient [ERC677].
     * If the recipient is a non-contract address this method behaves just like transfer.
     * @param to Recipient address.
     * @param amount Number of tokens to transfer.
     * @param data Additional data passed to the recipient's tokenFallback method.
     */
    function transferAndCall(address to, uint256 amount, bytes data) 
        external
        returns (bool ok) 
    {
        ok = controller.transferAndCall_withCaller(msg.sender, to, amount, data);
        emit Transfer(msg.sender, to, amount, data);
    }

    /**
     * @dev Gets the current controller.
     * @return Address of the controller.
     */
    function getController() external view returns (address) {
        return address(controller);
    }

    /**
     * @dev Returns the total supply.
     * @return Number of tokens.
     */
    function totalSupply() external view returns (uint) {
        return controller.totalSupply();
    }

    /**
     * @dev Returns the number tokens associated with an address.
     * @param who Address to lookup.
     * @return Balance of address.
     */
    function balanceOf(address who) external view returns (uint) {
        return controller.balanceOf(who);
    }

    /** 
     * @dev Returns the allowance for a spender 
     * @param owner The address of the owner of the tokens.
     * @param spender The address of the spender.
     * @return Number of tokens the spender is allowed to spend.
     */
    function allowance(address owner, address spender) external view returns (uint) {
        return controller.allowance(owner, spender);
    }

    /**
     * @dev Returns the number of decimals in one token. 
     * @return Number of decimals.
     */
    function decimals() external view returns (uint) {
        return controller.decimals();
    }

}
