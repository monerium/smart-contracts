// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.20;

import "./Token.sol";


contract TokenV2 is Token {
    function initializeV2() public virtual reinitializer(2) {
      // Add hardcoded allowance here.
      _approve(address(66), address(99), 12e18);

    }
}
