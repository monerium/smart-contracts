pragma solidity ^0.4.11;

import "./StandardController.sol";
import "./MintableTokenLib.sol";

contract MintableController is StandardController {
    using MintableTokenLib for TokenStorage;

    // EVENTS
    event Mint(address indexed to, uint amount);
    event Burn(address indexed from, uint amount);

    // CONSTRUCTOR
    function MintableController(address _storage, uint initialSupply) 
        StandardController(_storage, initialSupply) 
    { }

    // EXTERNAL
    function mint(uint amount) onlyOwner returns (bool) {
        return token.mint(msg.sender, amount);
    }

    function burn(uint amount) onlyOwner returns (bool) {
        return token.burn(msg.sender, amount);
    }

}
