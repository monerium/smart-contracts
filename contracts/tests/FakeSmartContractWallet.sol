// SPDX-License-Identifier: Apache 2.0
pragma solidity 0.8.11;

contract FakeSmartContractWallet {
    bytes4 internal constant MAGICVALUE = 0x1626ba7e;

    function isValidSignature(
        bytes32 hash,
        bytes memory _signature
    ) public view returns (bytes4) {
        return MAGICVALUE; // Always returns the magic value for 'true'
    }
}
