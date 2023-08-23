// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

// @title Force Ether into a contract.
// @notice  even
// if the contract is not payable.
// @notice To use, construct the contract with the target as argument.
// @author Remco Bloemen <remco@neufund.org>
contract ForceEther {
    constructor() payable {}

    function destroyAndSend(address payable _recipient) public {
        selfdestruct(_recipient);
    }
}
