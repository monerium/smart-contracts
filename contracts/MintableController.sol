pragma solidity ^0.4.24;

import "./StandardController.sol";
import "./MintableTokenLib.sol";

contract MintableController is StandardController {

    using MintableTokenLib for TokenStorage;

    // CONSTRUCTOR
    constructor(address _storage, uint initialSupply) 
        public
        StandardController(_storage, initialSupply) 
    { }

    // EXTERNAL
    function mint(uint amount) external onlyOwner returns (bool) {
        return token.mint(owner, amount);
    }

    function mintTo(
        address to,
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
            ecrecover(h, v, r, s) == to,
            "signature/hash does not recover to address"
        );
        return token.mint(to, amount);
    }
    
    function burn(uint amount) external onlyOwner returns (bool) {
        return token.burn(owner, amount);
    }

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