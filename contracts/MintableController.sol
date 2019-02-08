pragma solidity 0.4.24;

import "./StandardController.sol";
import "./MintableTokenLib.sol";
import "./SystemRole.sol";

/**
* @title MintableController
* @dev This contracts implements functionality allowing for minting and burning of tokens. 
*/
contract MintableController is SystemRole, StandardController {

    using MintableTokenLib for TokenStorage;

    /**
     * @dev Contract constructor.
     * @param storage_ Address of the token storage for the controller.
     * @param initialSupply The amount of tokens to mint upon creation. 
     */
    constructor(address storage_, uint initialSupply) 
        public
        StandardController(storage_, initialSupply) 
    { }

    /**
     * @dev Mints new tokens to the contract owner.
     * This is a convenience method for mintTo.
     * @param amount Number of tokens to mint.
     */
    function mint(uint amount) external onlySystemAccounts returns (bool) {
        return token.mint(msg.sender, amount);
    }

    /**
     * @dev Mints new tokens.
     * @param to Address to credit the tokens.
     * @param amount Number of tokens to mint.
     */
    function mintTo(address to, uint amount)
        external
        onlySystemAccounts
        returns (bool)
    {
        return token.mint(to, amount);
    }
    
    /**
     * @dev Burns tokens from the calling system account.
     * This removes the burned tokens from circulation.
     * @param amount Number of tokens to burn.
     */
    function burn(uint amount) external onlySystemAccounts returns (bool) {
        return token.burn(msg.sender, amount);
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
        onlySystemAccounts
        returns (bool)
    {
        return token.burn(from, amount, h, v, r, s);
    }

    /**
     * @dev Assigns the system role to an account.
     */
    function addSystemAccount(address account) public onlyOwner {
        super.addSystemAccount(account);
    }

    /**
     * @dev Removes the system role from an account.
     */
    function removeSystemAccount(address account) public  onlyOwner {
        super.removeSystemAccount(account);
    }

}
