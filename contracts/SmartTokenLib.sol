pragma solidity ^0.4.24;

import "./Validator.sol";

library SmartTokenLib {
    struct SmartTokenStorage {
        Validator validator;
    }

    // EXTERNAL
    function setValidator(SmartTokenStorage storage self, address _validator) 
        external 
    {
        self.validator = Validator(_validator);
    }

    // EXTERNAL CONSTANT
    function validate(SmartTokenStorage storage self, address _from, address _to, uint _value) 
        external
        returns (bool valid) 
    { 
        return self.validator.validate(_from, _to, _value);
    }

    function getValidator(SmartTokenStorage storage self) 
        external 
        view 
        returns (address) 
    {
        return address(self.validator);
    }

    // INTERNAL PURE
    function recover(address a, bytes32 h, uint8 v, bytes32 r, bytes32 s) 
        internal 
        pure
        returns (bool) 
    {
        return ecrecover(h, v, r, s) == a;
    }
}
