// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Token.sol";
import "../src/BlacklistValidatorUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "forge-std/console.sol";

contract MintableTokenTest is Test {
    Token public token;
    ERC1967Proxy public proxy;
    uint256 internal userPrivateKey;

    address owner = address(this);
    address user1 = vm.addr(1);
    address system = vm.addr(2);
    address admin = vm.addr(3);

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

        userPrivateKey = 0xabc123;

        assertEq(token.name(), "token");
        assertEq(token.owner(), address(this));
    }

    function test_owner_can_set_max_mint_allowance() public {
        token.setLimitCap(1000);
        assertEq(token.getLimitCap(), 1000);
    }

    function test_non_owner_cannot_set_max_mint_allowance() public {
        vm.startPrank(user1);
        vm.expectRevert(
            abi.encodeWithSignature(
                "OwnableUnauthorizedAccount(address)",
                user1
            )
        );
        token.setLimitCap(1000);
        vm.stopPrank();
    }

    function test_admin_can_set_mint_allowance() public {
        test_owner_can_set_max_mint_allowance();
        token.addAdminAccount(admin);
        vm.startPrank(admin);
        token.setMintingLimit(system, 500);
        vm.stopPrank();
        assertEq(token.mintingCurrentLimitOf(system), 500);
    }

    function test_admin_cannot_set_mint_allowance_above_max_mint_allowance()
        public
    {
        test_owner_can_set_max_mint_allowance();
        token.addAdminAccount(admin);
        vm.startPrank(admin);
        vm.expectRevert(abi.encodeWithSignature("RateLimit_LimitsTooHigh()"));
        token.setMintingLimit(system, 1500);
        vm.stopPrank();
    }

    function test_non_admin_cannot_set_mint_allowance() public {
        vm.expectRevert("SystemRole: caller is not an admin account");

        token.setMintingLimit(user1, 500);
    }

    function test_system_account_can_mint_tokens() public {
        test_owner_can_set_max_mint_allowance();
        test_admin_can_set_mint_allowance();
        token.addSystemAccount(system);
        address user = vm.addr(userPrivateKey);
        vm.startPrank(system);
        token.mint(user, 100);
        vm.stopPrank();

        assertEq(token.balanceOf(user), 100);
    }

    function test_system_account_cannot_mint_tokens_above_mint_allowance()
        public
    {
        test_owner_can_set_max_mint_allowance();
        test_admin_can_set_mint_allowance();
        token.addSystemAccount(system);
        address user = vm.addr(userPrivateKey);
        vm.startPrank(system);
        
        vm.expectRevert(abi.encodeWithSignature("IXERC20_NotHighEnoughLimits()"));
        token.mint(user, 1000);
        vm.stopPrank();
    }

    function test_non_system_account_cannot_mint_tokens() public {
        vm.expectRevert("SystemRole: caller is not a system account");
        token.mint(user1, 100);
    }

    function test_system_account_can_burn_tokens() public {
        test_owner_can_set_max_mint_allowance();
        test_admin_can_set_mint_allowance();
        test_system_account_can_mint_tokens();

        address user = vm.addr(userPrivateKey);
        bytes32 hash = 0xb77c35c892a1b24b10a2ce49b424e578472333ee8d2456234fff90626332c50f;
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, hash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.startPrank(system);
        token.burn(user, 50, hash, signature);
        vm.stopPrank();

        assertEq(token.balanceOf(user), 50);
    }

    function test_non_system_account_cannot_burn_tokens() public {
        test_owner_can_set_max_mint_allowance();
        test_admin_can_set_mint_allowance();
        test_system_account_can_mint_tokens();

        address user = vm.addr(userPrivateKey);
        bytes32 hash = keccak256(
            "I hereby declare that I am the address owner."
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, hash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.expectRevert("SystemRole: caller is not a system account");
        token.burn(user, 50, hash, signature);
    }

    function test_system_account_cannot_burn_tokens_with_invalid_signature()
        public
    {
        test_owner_can_set_max_mint_allowance();
        test_admin_can_set_mint_allowance();
        test_system_account_can_mint_tokens();

        address user = vm.addr(userPrivateKey);
        bytes32 hash2 = keccak256("Invalid burn");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, hash2);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.startPrank(system);
        vm.expectRevert("signature/hash does not match");
        token.burn(user, 50, hash2, signature);
        vm.stopPrank();
    }
}
