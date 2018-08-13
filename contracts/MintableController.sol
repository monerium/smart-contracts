pragma solidity ^0.4.24;

import "./StandardController.sol";
import "./MintableTokenLib.sol";

contract MintableController is StandardController {
    using MintableTokenLib for TokenStorage;

    // EVENTS
    event Mint(address indexed to, uint amount);
    event Burn(address indexed from, uint amount);

    // CONSTRUCTOR
    constructor(address _storage, uint initialSupply) 
        internal
        StandardController(_storage, initialSupply) 
    { }

    // EXTERNAL
    function mint(uint amount) external onlyOwner returns (bool) {
        return token.mint(msg.sender, amount);
    }

    function burn(uint amount) external onlyOwner returns (bool) {
        return token.burn(msg.sender, amount);
    }

}
