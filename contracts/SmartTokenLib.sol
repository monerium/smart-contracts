pragma solidity ^0.4.24;

import "./ERC20Lib.sol";
import "./MintableTokenLib.sol";
import "./IValidator.sol";

library SmartTokenLib {

    using ERC20Lib for TokenStorage;
    using MintableTokenLib for TokenStorage;

    struct SmartStorage {
        IValidator validator;
    }

    // EVENTS
    event Recovered(address indexed from, address indexed to, uint amount);

    // INTERNAL
    function setValidator(SmartStorage storage self, address validator) 
        internal 
    {
        self.validator = IValidator(validator);
    }

    function validate(SmartStorage storage self, address from, address to, uint value) 
        internal
        returns (bool valid) 
    { 
        return self.validator.validate(from, to, value);
    }

    function recover(
        TokenStorage token, 
        address from, 
        address to, 
        bytes32 h, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) 
        internal 
        returns (bool) 
    {
        require(
            ecrecover(h, v, r, s) == from,
            "signature/hash does not recover from address"
        );
        uint amount = token.balanceOf(from);
        require(token.burn(from, amount), "unable to burn tokens");
        require(token.mint(to, amount), "unable to mint tokens"); 
        emit Recovered(from, to, amount);
        return true;
    }

    // INTERNAL CONSTANT
    function getValidator(SmartStorage storage self) 
        external 
        view 
        returns (address) 
    {
        return address(self.validator);
    }

}
