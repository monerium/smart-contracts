/**
 * Copyright 2019 Monerium ehf.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/ownership/Claimable.sol";
import "openzeppelin-solidity/contracts/ownership/CanReclaimToken.sol";
import "openzeppelin-solidity/contracts/ownership/NoOwner.sol";
import "openzeppelin-solidity/contracts/lifecycle/Destructible.sol";
import "./IERC20.sol";
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
contract TokenFrontend is Destructible, Claimable, CanReclaimToken, NoOwner, IERC20 {

    SmartController internal controller;

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
     * @dev Emitted when updating the controller.
     * @param ticker Three letter ticker representing the currency.
     * @param old Address of the old controller.
     * @param current Address of the new controller.
     */
    event Controller(bytes3 indexed ticker, address indexed old, address indexed current);

    /**
     * @dev Contract constructor.
     * @notice The contract is an abstract contract as a result of the internal modifier.
     * @param name_ Token name.
     * @param symbol_ Token symbol.
     * @param ticker_ 3 letter currency ticker.
     */
    constructor(string name_, string symbol_, bytes3 ticker_) internal {
        name = name_;
        symbol = symbol_;
        ticker = ticker_;
    }

    /**
     * @dev Sets a new controller.
     * @param address_ Address of the controller.
     */
    function setController(address address_) external onlyOwner {
        require(address_ != 0x0, "controller address cannot be the null address");
        emit Controller(ticker, controller, address_);
        controller = SmartController(address_);
        require(controller.getFrontend() == address(this), "controller frontend does not point back");
        require(controller.ticker() == ticker, "ticker does not match controller ticket");
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
     * @dev Mints new tokens.
     * @param to Address to credit the tokens.
     * @param amount Number of tokens to mint.
     */
    function mintTo(address to, uint amount)
        external
        returns (bool ok)
    {
        ok = controller.mintTo_withCaller(msg.sender, to, amount);
        emit Transfer(0x0, to, amount);
    }

    /**
     * @dev Burns tokens from token owner.
     * This removfes the burned tokens from circulation.
     * @param from Address of the token owner.
     * @param amount Number of tokens to burn.
     * @param h Hash which the token owner signed.
     * @param v Signature component.
     * @param r Signature component.
     * @param s Sigature component.
     */
    function burnFrom(address from, uint amount, bytes32 h, uint8 v, bytes32 r, bytes32 s)
        external
        returns (bool ok)
    {
        ok = controller.burnFrom_withCaller(msg.sender, from, amount, h, v, r, s);
        emit Transfer(from, 0x0, amount);
    }

    /**
     * @dev Recovers tokens from an address and reissues them to another address.
     * In case a user loses its private key the tokens can be recovered by burning
     * the tokens from that address and reissuing to a new address.
     * To recover tokens the contract owner needs to provide a signature
     * proving that the token owner has authorized the owner to do so.
     * @param from Address to burn tokens from.
     * @param to Address to mint tokens to.
     * @param h Hash which the token owner signed.
     * @param v Signature component.
     * @param r Signature component.
     * @param s Sigature component.
     * @return Amount recovered.
     */
    function recover(address from, address to, bytes32 h, uint8 v, bytes32 r, bytes32 s)
        external
        returns (uint amount)
    {
        amount = controller.recover_withCaller(msg.sender, from, to, h ,v, r, s);
        emit Transfer(from, to, amount);
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
