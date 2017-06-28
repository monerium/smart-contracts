pragma solidity ^0.4.11;

import "./ConstantValidator.sol";
import "./SmartController.sol";

contract ConstantSmartController is SmartController {

    // CONSTRUCTOR
    function ConstantSmartController(address _storage, bytes3 _ticker) 
        SmartController(_storage, new ConstantValidator(false), _ticker)
    {

    }
}
