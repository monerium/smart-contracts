pragma solidity ^0.4.24;

import "./ConstantValidator.sol";
import "./SmartController.sol";

contract ConstantSmartController is SmartController {

    // CONSTRUCTOR
    constructor(address storage_, bytes3 ticker) 
        public
        SmartController(storage_, new ConstantValidator(false), ticker)
    { }

}
