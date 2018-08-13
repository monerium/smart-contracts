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
        view
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
}
