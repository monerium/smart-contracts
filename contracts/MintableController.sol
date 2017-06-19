pragma solidity ^0.4.10;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./StandardController.sol";
import "./MintableTokenLib.sol";

contract MintableController is StandardController, Ownable {
    using MintableTokenLib for EternalTokenStorage.TokenStorage;

    function MintableController(address _frontend) 
        StandardController(_frontend) { }

    function mint(uint amount) onlyOwner returns (bool) {
        return token.mint(msg.sender, amount);
    }

    function burn(uint amount) onlyOwner returns (bool) {
        return token.burn(msg.sender, amount);
    }
}
