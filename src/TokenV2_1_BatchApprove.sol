// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.20;

import "./Token.sol";

contract TokenV2_1_BatchApprove is Token {
    function batchApprove(
        address[] calldata _owner,
        address[] calldata _spender,
        uint256[] calldata _value
    ) external onlyOwner {
        require(
            _owner.length == _spender.length &&
                _spender.length == _value.length,
            "Invalid input"
        );
        for (uint256 i = 0; i < _owner.length; i++) {
            //  Checking if an allowance is already set.
            if (allowance(_owner[i], _spender[i]) == 0)
                _approve(_owner[i], _spender[i], _value[i]);
        }
    }
}
