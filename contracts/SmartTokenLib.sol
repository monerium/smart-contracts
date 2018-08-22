pragma solidity ^0.4.24;

import "./ERC20Lib.sol";
import "./MintableTokenLib.sol";
import "./Validator.sol";

library SmartTokenLib {

    struct SmartStorage {
        Validator validator;
    }

    // EVENTS
    event Recovered(address indexed from, address indexed to, uint amount);

    // EXTERNAL
    function setValidator(SmartStorage storage self, address validator) 
        external 
    {
        self.validator = Validator(validator);
    }

    // EXTERNAL CONSTANT
    function validate(SmartStorage storage self, address from, address to, uint value) 
        external
        returns (bool valid) 
    { 
        return self.validator.validate(from, to, value);
    }

    function getValidator(SmartStorage storage self) 
        external 
        view 
        returns (address) 
    {
        return address(self.validator);
    }

    // INTERNAL 
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
        uint amount = ERC20Lib.balanceOf(token, from);
        require(MintableTokenLib.burn(token, from, amount), "unable to burn tokens");
        require(MintableTokenLib.mint(token, to, amount), "unable to mint tokens"); 
        emit Recovered(from, to, amount);
        return true;
    }

}
