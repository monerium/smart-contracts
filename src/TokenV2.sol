// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.20;

import "./Token.sol";


contract TokenV2 is Token {

  function batchApprove(address[] calldata _from, address[] calldata _to, uint256[] calldata _value) external onlyOwner {
    require(_from.length == _to.length && _to.length == _value.length, "Invalid input");
    for (uint256 i = 0; i < _from.length; i++) {
      _approve(_from[i], _to[i], _value[i]);
    }
  }

}
