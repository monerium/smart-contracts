pragma solidity ^0.4.24;

/**
 * @title UIntLib
 * @dev Helper functions for signing unsigned integers.
 */
library UIntLib {
    /**
     * @dev Hashes the number with an Ethereum specific prefix.
     */
    function toEthereumSignedMessage(uint n) internal pure returns (bytes32) {
        string memory message = toString(n);
        uint len = bytes(message).length;
        require(len > 0, "message must be non-zero");
        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        return keccak256(abi.encodePacked(prefix, toString(len), message));
    }

    /**
     * @dev Converts an unsigned integer to a string.
     */
    function toString(uint n) internal pure returns (string) {
        if (n == 0) return "0";
        uint i = n;
        uint j = n;
        uint len;
        while (j != 0){
            len++;
            j /= 10;
        }
        bytes memory bs = new bytes(len);
        uint k = len - 1;
        while (i != 0){
            bs[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bs);
    }

}
