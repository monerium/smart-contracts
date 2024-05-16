// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import "../IValidator.sol";

/**
 * @title NotAMoneriumValidator
 * @dev  This contract is not a Monerium validator.
 */
contract NotAMoneriumValidator is IValidator {
    bytes32 private constant ID =
        0x0000000000000000000000000000000000000000000000000000000000000000;

    /**
     * @dev returns the contract identifier.
     */
    function CONTRACT_ID() public pure returns (bytes32) {
        return ID;
    }

    /**
     * @dev Validates token transfer.
     * Implements IValidator interface.
     */
    function validate(
        address ,
        address ,
        uint256 
    ) external returns (bool valid) {}

}

