// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Token.sol";
import "../src/BlacklistValidatorUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract TokenTest is Test {
    Token public token;
    ERC1967Proxy public proxy;
    address public newImplementation;

    address system = vm.addr(1);
    address admin = vm.addr(2);
    address user1 = vm.addr(3);
    address user2 = vm.addr(4);

    function setUp() public {
        // Deploy the implementation contract
        Token implementation = new Token();
        BlacklistValidatorUpgradeable blacklistValidator = new BlacklistValidatorUpgradeable();

        // Deploy the proxy contract
        ERC1967Proxy validatorProxy = new ERC1967Proxy(
            address(blacklistValidator),
            ""
        );

        bytes memory initData = abi.encodeWithSelector(
            Token.initialize.selector,
            "token",
            "EURE",
            address(validatorProxy)
        );
        proxy = new ERC1967Proxy(address(implementation), initData);

        // Cast the proxy address to the Token interface
        token = Token(address(proxy));

        // Prepare a new implementation for upgrade testing
        newImplementation = address(new Token());

        token.addSystemAccount(system);
        token.addAdminAccount(admin);
        assertTrue(token.isSystemAccount(system));
        assertTrue(token.isAdminAccount(admin));
        token.setMaxMintAllowance(1e18);
        vm.prank(admin);
        token.setMintAllowance(system, 1e18);
    }

    function test_deployment() public {
        // Check if the token name and symbol are correctly set
        assertEq(token.name(), "token");
        assertEq(token.symbol(), "EURE");
    }

    function test_upgrade() public {
        // Upgrade the contract using the new upgrade mechanism
        // You can pass initialization data for the new implementation if needed. In our case, we don't need it.
        bytes memory data = "";
        token.upgradeToAndCall(newImplementation, data);

        // Cast the proxy address to the new Token interface
        // After the upgrade, you need to interact with the proxy as if it were the new implementation.
        // The casting ensures that you're using the updated contract interface.
        Token newToken = Token(address(proxy));

        assertEq(token.name(), newToken.name());
        assertEq(token.symbol(), newToken.symbol());
    }

    function test_keep_balances_after_upgrade() public {
        vm.prank(system);
        token.mint(user1, 1e18);

        // Upgrade the contract using the new upgrade mechanism
        // You can pass initialization data for the new implementation if needed. In our case, we don't need it.
        bytes memory data = "";
        token.upgradeToAndCall(newImplementation, data);

        // Cast the proxy address to the new Token interface
        // After the upgrade, you need to interact with the proxy as if it were the new implementation.
        // The casting ensures that you're using the updated contract interface.
        Token newToken = Token(address(proxy));

        assertEq(newToken.balanceOf(user1), 1e18);
    }

    function test_keep_roles_after_upgrade() public {
        // Verify initial roles before the upgrade
        assertTrue(token.isSystemAccount(system));
        assertTrue(token.isAdminAccount(admin));

        // Upgrade the contract
        bytes memory data = "";
        token.upgradeToAndCall(newImplementation, data);

        // Cast the proxy address to the new Token interface
        Token newToken = Token(address(proxy));

        // Verify roles after the upgrade
        assertTrue(newToken.isSystemAccount(system));
        assertTrue(newToken.isAdminAccount(admin));
    }

    function test_keep_allowances_after_upgrade() public {
        vm.prank(user1);
        token.approve(user2, 1e18);

        // Check initial allowance
        assertEq(token.allowance(user1, user2), 1e18);

        // Upgrade the contract
        bytes memory data = "";
        token.upgradeToAndCall(newImplementation, data);

        // Cast the proxy address to the new Token interface
        Token newToken = Token(address(proxy));

        // Check allowance after upgrade
        assertEq(newToken.allowance(user1, user2), 1e18);
    }

    function test_keep_mint_allowance_after_upgrade() public {
        // Check initial mint allowance
        assertEq(token.getMintAllowance(system), 1e18);

        // Upgrade the contract
        bytes memory data = "";
        token.upgradeToAndCall(newImplementation, data);

        // Cast the proxy address to the new Token interface
        Token newToken = Token(address(proxy));

        // Check mint allowance after upgrade
        assertEq(newToken.getMintAllowance(system), 1e18);
    }

    function test_keep_max_mint_allowance_after_upgrade() public {
        // Check initial max mint allowance
        assertEq(token.getMaxMintAllowance(), 1e18);

        // Upgrade the contract
        bytes memory data = "";
        token.upgradeToAndCall(newImplementation, data);

        // Cast the proxy address to the new Token interface
        Token newToken = Token(address(proxy));

        // Check max mint allowance after upgrade
        assertEq(newToken.getMaxMintAllowance(), 1e18);
    }
}
