pragma solidity ^0.4.10;

import "./StandardController.sol";
import "./MintableTokenLib.sol";

contract MintableController is StandardController {
    using MintableTokenLib for TokenStorage;

    function MintableController(address _frontend, address _storage, uint initialSupply) 
        StandardController(_frontend, _storage, initialSupply) { }

    function mint(uint amount) onlyOwner returns (bool) {
        return token.mint(msg.sender, amount);
    }

    function burn(uint amount) onlyOwner returns (bool) {
        return token.burn(msg.sender, amount);
    }

    event Mint(address indexed to, uint amount);
    event Burn(address indexed from, uint amount);
}
