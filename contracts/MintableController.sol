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
     * To burn tokens the contract owner needs to provide a signature
     * proving that the token owner has authorized the owner to do so.
     * @param from Address of the token owner.
     * @param amount Number of tokens to burn.
     * @param h Hash which the token owner signed.
     * @param v Signature component.
     * @param r Signature component.
     * @param s Sigature component.
     */
    function burnFrom(
        address from,
        uint amount,
        bytes32 h,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        onlyOwner
        returns (bool)
    {
        require(
            ecrecover(h, v, r, s) == from,
            "signature/hash does not recover from address"
        );
        return token.burn(from, amount);
    }
    
}
