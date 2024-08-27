// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Token.sol";
import "../src/TokenV2.sol";
import "../src/BlacklistValidatorUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract TokenTest is Test {
    Token public token;
    ERC1967Proxy public proxy;

    function setUp() public {
        // Deploy the initial implementation contract
        Token implementation = new Token();
        BlacklistValidatorUpgradeable blacklistValidator = new BlacklistValidatorUpgradeable();

        // Deploy the validator proxy contract
        ERC1967Proxy validatorProxy = new ERC1967Proxy(
            address(blacklistValidator),
            ""
        );

        // Initialize the Token with the proxy
        bytes memory initData = abi.encodeWithSelector(
            Token.initialize.selector,
            "token",
            "EURE",
            address(validatorProxy)
        );
        proxy = new ERC1967Proxy(address(implementation), initData);

        // Cast the proxy address to the Token interface
        token = Token(address(proxy));
    }

    function testUpgradeToV2() public {
        // Verify initial state
        assertEq(token.name(), "token");
        assertEq(token.symbol(), "EURE");

        // Deploy the new TokenV2 implementation contract
        TokenV2 newImplementation = new TokenV2();

        // Encode the initializeV2 call
        bytes memory data = abi.encodeWithSelector(
            TokenV2.initializeV2.selector
        );

        // Upgrade the proxy to use the new implementation contract and call initializeV2
        token.upgradeToAndCall(address(newImplementation), data);

        // Cast the proxy address to the TokenV2 interface
        TokenV2 upgradedToken = TokenV2(address(proxy));

        // Verify the upgrade was successful
        assertEq(token.allowance(address(66), address(99)), 12e18);
        assertEq(upgradedToken.name(), "token");
        assertEq(upgradedToken.symbol(), "EURE");
    }
}
