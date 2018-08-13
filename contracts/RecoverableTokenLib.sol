pragma solidity ^0.4.24;

library RecoverableTokenLib {

    function recover(bytes32 h, uint8 v, bytes32 r, bytes32 s) 
        internal 
        pure
        returns (address) 
    {
        return ecrecover(h, v, r, s);
    }

}