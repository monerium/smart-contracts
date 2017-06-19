pragma solidity ^0.4.10;

// import "zeppelin-solidity/contracts/token/ERC20Lib.sol";
// import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./StandardController.sol";
import "./MintableTokenLib.sol";

contract MintableController is StandardController {
    using MintableTokenLib for EternalTokenStorage.TokenStorage;

    function mint(address to, uint amount) onlyOwner returns (bool) {
        return token.mint(to, amount);
    }
}
