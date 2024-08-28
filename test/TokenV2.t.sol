// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Token.sol";
import "../src/TokenV2.sol";
import "../src/BlacklistValidatorUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract TokenTest is Test {
    TokenV2 public tokenV2;
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
        tokenV2 = TokenV2(address(proxy));
    }

    function testUpgradeToV2() public {
        // Verify initial state
        assertEq(tokenV2.name(), "token");
        assertEq(tokenV2.symbol(), "EURE");

        // Deploy the new TokenV2 implementation contract
        TokenV2 newImplementation = new TokenV2();

        bytes memory data = "";
        // Upgrade the proxy to use the new implementation contract
        tokenV2.upgradeToAndCall(address(newImplementation), data);

        // Cast the proxy address to the TokenV2 interface
        TokenV2 upgradedToken = TokenV2(address(proxy));

        // Verify the upgrade was successful
        assertEq(upgradedToken.name(), "token");
        assertEq(upgradedToken.symbol(), "EURE");
    }

    function testBatchApprove() public {
        // Deploy the new TokenV2 implementation contract
        TokenV2 newImplementation = new TokenV2();

        // Upgrade the proxy to use the new implementation contract
        bytes memory data = "";
        tokenV2.upgradeToAndCall(address(newImplementation), data);

        // Cast the proxy address to the TokenV2 interface
        TokenV2 upgradedToken = TokenV2(address(proxy));

        // Create dummy addresses and values for testing
        address[] memory from = new address[](3);
        address[] memory to = new address[](3);
        uint256[] memory values = new uint256[](3);

        from[0] = address(0x123);
        from[1] = address(0x456);
        from[2] = address(0x789);

        to[0] = address(0xabc);
        to[1] = address(0xdef);
        to[2] = address(0xded);

        values[0] = 100;
        values[1] = 200;
        values[2] = 300;

        // Call batchApprove function
        upgradedToken.batchApprove(from, to, values);

        // Verify the approvals
        assertEq(upgradedToken.allowance(from[0], to[0]), values[0]);
        assertEq(upgradedToken.allowance(from[1], to[1]), values[1]);
        assertEq(upgradedToken.allowance(from[2], to[2]), values[2]);
    }

     function testFail_BatchApproveShouldFailIfNotOwner() public {
        // Deploy the new TokenV2 implementation contract
        TokenV2 newImplementation = new TokenV2();

        // Upgrade the proxy to use the new implementation contract
        bytes memory data = "";
        tokenV2.upgradeToAndCall(address(newImplementation), data);

        // Cast the proxy address to the TokenV2 interface
        TokenV2 upgradedToken = TokenV2(address(proxy));

        // Create dummy addresses and values for testing
        address[] memory from = new address[](3);
        address[] memory to = new address[](3);
        uint256[] memory values = new uint256[](3);

        from[0] = address(0x123);
        from[1] = address(0x456);
        from[2] = address(0x789);

        to[0] = address(0xabc);
        to[1] = address(0xdef);
        to[2] = address(0xded);

        values[0] = 100;
        values[1] = 200;
        values[2] = 300;

        // Call batchApprove function
        vm.prank(address(0x123));
        upgradedToken.batchApprove(from, to, values);

        // Verify the approvals
        assertEq(upgradedToken.allowance(from[0], to[0]), values[0]);
        assertEq(upgradedToken.allowance(from[1], to[1]), values[1]);
        assertEq(upgradedToken.allowance(from[2], to[2]), values[2]);
    }

}
