pragma solidity ^0.4.10;

// import "zeppelin-solidity/contracts/SafeMathLib.sol";
import "./Validator.sol";

library SmartTokenLib {
    // using SafeMathLib for uint;

    struct SmartTokenStorage {
        // address validator;
        Validator validator;
    }

    // external
    function getValidator(SmartTokenStorage storage self) constant returns (address) {
        return address(self.validator);
    }

    function setValidator(SmartTokenStorage storage self, address _validator) {
        self.validator = Validator(_validator);
    }

    function validate(SmartTokenStorage storage self, address _from, address _to, uint _value) 
        returns (bool valid) 
    { 
        return self.validator.validate(_from, _to, _value);
    }
}
