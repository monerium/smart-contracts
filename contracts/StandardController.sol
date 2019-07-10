pragma solidity 0.4.24;


import "./TokenStorage.sol";
import "./ERC20Lib.sol";
import "./ERC677Lib.sol";
import "openzeppelin-solidity/contracts/ownership/Claimable.sol";
import "openzeppelin-solidity/contracts/ownership/CanReclaimToken.sol";
import "openzeppelin-solidity/contracts/ownership/NoOwner.sol";
import "openzeppelin-solidity/contracts/lifecycle/Destructible.sol";
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";

/**
 * @title StandardController
 * @dev This is the base contract which delegates token methods [ERC20 and ERC677]
 * to their respective library implementations.
 * The controller is primarily intended to be interacted with via a token frontend.
 */
contract StandardController is Pausable, Destructible, Claimable, CanReclaimToken, NoOwner {

    using ERC20Lib for TokenStorage;
    using ERC677Lib for TokenStorage;

    TokenStorage internal token;
    address internal frontend;

    string public name;
    string public symbol;
    uint public decimals = 18;

    /**
     * @dev Emitted when updating the frontend.
     * @param old Address of the old frontend.
     * @param current Address of the new frontend.
     */
    event Frontend(address indexed old, address indexed current);

    /**
     * @dev Emitted when updating the storage.
     * @param old Address of the old storage.
     * @param current Address of the new storage.
     */
    event Storage(address indexed old, address indexed current);

    /**
     * @dev Modifier which prevents the function from being called by unauthorized parties.
     * The caller must either be the sender or the function must be
     * called via the frontend, otherwise the call is reverted.
     * @param caller The address of the passed-in caller. Used to preserve the original caller.
     */
    modifier guarded(address caller) {
        require(
            msg.sender == caller || msg.sender == frontend,
            "either caller must be sender or calling via frontend"
        );
        _;
    }

    /**
     * @dev Modifier which prevents tokens to be sent to well known blackholes.
     * @param to The address of the intended recipient.
     */
    modifier avoidBlackholes(address to) {
        require(to != 0x0, "must not send to 0x0");
        require(to != address(this), "must not send to controller");
        // require(to != address(token), "must not send to token storage");
        require(to != frontend, "must not send to frontend");
        _;
    }

    /**
     * @dev Contract constructor.
     * @param storage_ Address of the token storage for the controller.
     * @param initialSupply The amount of tokens to mint upon creation.
     * @param frontend_ Address of the authorized frontend.
     */
    constructor(address storage_, uint initialSupply, address frontend_) public {
        require(
            storage_ == 0x0 || initialSupply == 0,
            "either a token storage must be initialized or no initial supply"
        );
        if (storage_ == 0x0) {
            token = new TokenStorage();
            token.addBalance(msg.sender, initialSupply);
        } else {
            token = TokenStorage(storage_);
        }
        frontend = frontend_;
    }

    /**
     * @dev Returns the current frontend.
     * @return Address of the frontend.
     */
    function getFrontend() external view returns (address) {
        return frontend;
    }

    /**
     * @dev Returns the current storage.
     * @return Address of the storage.
     */
    function getStorage() external view returns (address) {
        return address(token);
    }

    /**
     * @dev Sets a new frontend.
     * @param frontend_ Address of the new frontend.
     */
    function setFrontend(address frontend_) public onlyOwner {
        emit Frontend(frontend, frontend_);
        frontend = frontend_;
    }

    /**
     * @dev Sets a new storage.
     * @param storage_ Address of the new storage.
     */
    function setStorage(address storage_) external onlyOwner {
        emit Storage(address(token), storage_);
        token = TokenStorage(storage_);
    }

    /**
     * @dev Transfers the ownership of the storage.
     * @param newOwner Address of the new storage owner.
     */
    function transferStorageOwnership(address newOwner) public onlyOwner {
        token.transferOwnership(newOwner);
    }

    /**
     * @dev Claims the ownership of the storage.
     */
    function claimStorageOwnership() public onlyOwner {
        token.claimOwnership();
    }

   /**
     * @dev Transfers tokens [ERC20].
     * See transfer_withCaller for documentation.
     */
    function transfer(address to, uint amount)
        external
        returns (bool ok)
    {
        return transfer_withCaller(msg.sender, to, amount);
    }

    /**
     * @dev Transfers tokens from a specific address [ERC20].
     * See transferFrom_withCaller for documentation.
     */
    function transferFrom(address from, address to, uint amount)
        external
        returns (bool ok)
    {
        return transferFrom_withCaller(msg.sender, from, to, amount);
    }

    /**
     * @dev Approves a spender [ERC20].
     * See approve_withCaller for documentation.
     */
    function approve(address spender, uint amount)
        external
        returns (bool ok)
    {
        return approve_withCaller(msg.sender, spender, amount);
    }

    /**
     * @dev Transfers tokens and subsequently calls a method on the recipient [ERC677].
     * See transferAndCAll_withCaller for documentation.
     */
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

    /**
     * @dev Transfers tokens [ERC20].
     * @param caller Address of the caller passed through the frontend.
     * @param to Recipient address.
     * @param amount Number of tokens to transfer.
     */
    function transfer_withCaller(address caller, address to, uint amount)
        public
        guarded(caller)
        avoidBlackholes(to)
        whenNotPaused
        returns (bool ok)
    {
        return token.transfer(caller, to, amount);
    }

    /**
     * @dev Transfers tokens from a specific address [ERC20].
     * The address owner has to approve the spender beforehand.
     * @param caller Address of the caller passed through the frontend.
     * @param from Address to debet the tokens from.
     * @param to Recipient address.
     * @param amount Number of tokens to transfer.
     */
    function transferFrom_withCaller(address caller, address from, address to, uint amount)
        public
        guarded(caller)
        avoidBlackholes(to)
        whenNotPaused
        returns (bool ok)
    {
        return token.transferFrom(caller, from, to, amount);
    }

    /**
     * @dev Approves a spender [ERC20].
     * Note that using the approve/transferFrom presents a possible
     * security vulnerability described in:
     * https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/edit#heading=h.quou09mcbpzw
     * Use transferAndCall to mitigate.
     * @param caller Address of the caller passed through the frontend.
     * @param spender The address of the future spender.
     * @param amount The allowance of the spender.
     */
    function approve_withCaller(address caller, address spender, uint amount)
        public
        guarded(caller)
        whenNotPaused
        returns (bool ok)
    {
        return token.approve(caller, spender, amount);
    }

    /**
     * @dev Transfers tokens and subsequently calls a method on the recipient [ERC677].
     * If the recipient is a non-contract address this method behaves just like transfer.
     * @param caller Address of the caller passed through the frontend.
     * @param to Recipient address.
     * @param amount Number of tokens to transfer.
     * @param data Additional data passed to the recipient's tokenFallback method.
     */
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

    /**
     * @dev Returns the total supply.
     * @return Number of tokens.
     */
    function totalSupply() external view returns (uint) {
        return token.getSupply();
    }

    /**
     * @dev Returns the number tokens associated with an address.
     * @param who Address to lookup.
     * @return Balance of address.
     */
    function balanceOf(address who) external view returns (uint) {
        return token.getBalance(who);
    }

    /**
     * @dev Returns the allowance for a spender
     * @param owner The address of the owner of the tokens.
     * @param spender The address of the spender.
     * @return Number of tokens the spender is allowed to spend.
     */
    function allowance(address owner, address spender) external view returns (uint) {
        return token.allowance(owner, spender);
    }

}
