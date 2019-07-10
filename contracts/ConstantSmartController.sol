pragma solidity 0.4.24;

import "./ConstantValidator.sol";
import "./SmartController.sol";

/**
 * @title ConstantSmartController
 * @dev Constantly rejects token transfers by using a rejecting validator.
 */
contract ConstantSmartController is SmartController {

    /**
     * @dev Contract constructor.
     * @param storage_ Address of the new storage.
     * @param ticker 3 letter currency ticker.
     */
    constructor(address storage_, bytes3 ticker)
        public
        SmartController(storage_, new ConstantValidator(false), ticker, 0x0)
    { }

}
