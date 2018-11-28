pragma solidity ^0.4.24;

import "./StandardController.sol";
import "./MintableTokenLib.sol";

/**
* @title MintableController
* @dev This contracts implements functionality allowing for minting and burning of tokens. 
*/
contract MintableController is StandardController {

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
    function mint(uint amount) external onlyOwner returns (bool) {
        return token.mint(owner, amount);
    }

    /**
     * @dev Mints new tokens.
     * @param to Address to credit the tokens.
     * @param amount Number of tokens to mint.
     */
    function mintTo(address to, uint amount)
        external
        onlyOwner
        returns (bool)
    {
        return token.mint(to, amount);
    }
    
    /**
     * @dev Burns tokens from the contract owner.
     * This removes the burned tokens from circulation.
     * @param amount Number of tokens to burn.
     */
    function burn(uint amount) external onlyOwner returns (bool) {
        return token.burn(owner, amount);
    }

    /**
     * @dev Burns tokens from token owner.
     * This removfes the burned tokens from circulation.
     * @param from Address of the token owner.
     * @param amount Number of tokens to burn.
     */
    function burnFrom(
        address from,
        uint amount
    )
        external
        onlyOwner
        returns (bool)
    {
        return token.burn(from, amount);
    }

}
