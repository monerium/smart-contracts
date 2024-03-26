// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Token.sol";
import "../src/BlacklistValidatorUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "forge-std/console.sol";

//import "forge-std/Vm.sol";

contract BlackListValidatorTest is Test {
    Token public token;
    ERC1967Proxy public proxy;
    BlacklistValidatorUpgradeable public validator;

    address owner = address(this);

    address user1 = vm.addr(1);
    address user2 = vm.addr(2);
    address system = vm.addr(3);
    address admin = vm.addr(4);

    function setUp() public {
        // Deploy the implementation contract
        Token implementation = new Token();
        BlacklistValidatorUpgradeable blacklistValidator = new BlacklistValidatorUpgradeable();

        // Deploy the proxy contract
        bytes memory initDataProxy = abi.encodeWithSelector(
            BlacklistValidatorUpgradeable.initialize.selector
        );
        ERC1967Proxy validatorProxy = new ERC1967Proxy(
            address(blacklistValidator),
            initDataProxy
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
        validator = BlacklistValidatorUpgradeable(address(validatorProxy));

        assertEq(token.name(), "token");
        assertEq(token.owner(), address(this));

        // Init the validator with an admin
        validator.addAdminAccount(admin);

        // Init the Token contract for minting and transfer test.
        token.addSystemAccount(system);
        token.addAdminAccount(admin);
        assertTrue(token.isSystemAccount(system));
        assertTrue(token.isAdminAccount(admin));
        token.setMaxMintAllowance(2e18);
        vm.prank(admin);
        token.setMintAllowance(system, 2e18);
        vm.startPrank(system);
        token.mint(user1, 1e18);
        token.mint(user2, 1e18);
        vm.stopPrank();
    }

    function test_ban() public {
        // Add user1 to blacklist
        vm.prank(admin);
        validator.ban(user1);
        assertTrue(validator.isBan(user1));
    }

    function test_unban() public {
        // Add user1 to blacklist
        vm.prank(admin);
        validator.ban(user1);
        assertTrue(validator.isBan(user1));

        // Remove user1 from blacklist
        vm.prank(admin);
        validator.unban(user1);
        assertTrue(!validator.isBan(user1));
    }

    function test_non_admin_cannot_ban() public {
        vm.expectRevert(abi.encodeWithSignature("Unauthorized()"));
        validator.ban(user1);
    }

    function test_can_remove_admin() public {
        // Add user1 to blacklist
        assertTrue(validator.isAdminAccount(admin));
        vm.prank(admin);
        validator.ban(user1);
        assertTrue(validator.isBan(user1));

        // Remove user1 from blacklist
        validator.removeAdminAccount(admin);
        assertTrue(!validator.isAdminAccount(admin));
        vm.prank(admin);
        vm.expectRevert(abi.encodeWithSignature("Unauthorized()"));
        validator.unban(user1);
    }

    function test_non_admin_cannot_unban() public {
        // Add user1 to blacklist
        vm.prank(admin);
        validator.ban(user1);
        assertTrue(validator.isBan(user1));

        // Remove user1 from blacklist
        vm.expectRevert(abi.encodeWithSignature("Unauthorized()"));
        validator.unban(user1);
    }

    function test_from_non_banned_user_should_validate() public {
        assertTrue(validator.validate(user1, user2, 1));
    }

    function test_from_banned_user_should_not_validate() public {
        // Add user1 to blacklist
        vm.prank(admin);
        validator.ban(user1);
        assertTrue(validator.isBan(user1));

        assertTrue(!validator.validate(user1, user2, 1));
    }

    function test_to_non_banned_user_should_validate() public {
        assertTrue(validator.validate(user2, user1, 1));
    }

    function test_to_banned_user_should_validate() public {
        // Add user1 to blacklist
        vm.prank(admin);
        validator.ban(user1);
        assertTrue(validator.isBan(user1));

        assertTrue(validator.validate(user2, user1, 1));
    }

    function test_from_banned_user_should_not_transfer() public {
        // Add user1 to blacklist
        vm.prank(admin);
        validator.ban(user1);
        assertTrue(validator.isBan(user1));

        vm.expectRevert("Transfer not validated");
        vm.prank(user1);
        token.transfer(user2, 1);
    }

    function test_to_banned_user_should_transfer() public {
        // Add user2 to blacklist
        vm.prank(admin);
        validator.ban(user2);
        assertTrue(validator.isBan(user2));

        vm.prank(user1);
        token.transfer(user2, 1);
    }

    function test_from_banned_user_should_not_transferFrom() public {
        // Add user1 to blacklist
        vm.prank(admin);
        validator.ban(user1);
        assertTrue(validator.isBan(user1));

        vm.prank(user1);
        token.approve(user2, 1e18);

        vm.prank(user2);
        vm.expectRevert("Transfer not validated");
        token.transferFrom(user1, user2, 1);
    }

    function test_to_banned_user_should_transferFrom() public {
        // Add user2 to blacklist
        vm.prank(admin);
        validator.ban(user2);
        assertTrue(validator.isBan(user2));

        vm.prank(user1);
        token.approve(user2, 1e18);

        vm.prank(user2);
        token.transferFrom(user1, user2, 1);
    }

    function test_new_blacklistValidator() public {
        BlacklistValidatorUpgradeable bv = new BlacklistValidatorUpgradeable();

        // Deploy the proxy contract
        bytes memory initDataProxy = abi.encodeWithSelector(
            BlacklistValidatorUpgradeable.initialize.selector
        );
        ERC1967Proxy validatorProxy = new ERC1967Proxy(
            address(bv),
            initDataProxy
        );

        BlacklistValidatorUpgradeable newValidator = BlacklistValidatorUpgradeable(
                address(validatorProxy)
            );
        newValidator.addAdminAccount(admin);
        vm.prank(admin);
        newValidator.ban(user1);

        assertTrue(newValidator.isBan(user1));

        vm.prank(user1);
        token.transfer(user2, 5e17);

        assertEq(token.balanceOf(user1), 5e17);

        token.setValidator(address(newValidator));

        vm.prank(user1);
        vm.expectRevert("Transfer not validated");
        token.transfer(user2, 5e17);
    }

    function test_upgrade_blacklistValidator() public {
        vm.prank(admin);
        validator.ban(user1);
        assertTrue(validator.isBan(user1));
        BlacklistValidatorUpgradeable bv = new BlacklistValidatorUpgradeable();

        // Upgrade without calling the initialize
        validator.upgradeToAndCall(address(bv), "");

        assertTrue(validator.isBan(user1));

        vm.prank(user1);
        vm.expectRevert("Transfer not validated");
        token.transfer(user2, 1e18);
    }

}

