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

        token.addSystemAccount(system);
        token.addAdminAccount(admin);
    }

    function test_owner_can_set_limit_cap() public {
        token.setLimitCap(200 ether);
        assertEq(token.getLimitCap(), 200 ether);
    }

    function test_non_owner_cannot_set_limit_cap() public {
        vm.startPrank(user1);
        vm.expectRevert(
            abi.encodeWithSignature(
                "OwnableUnauthorizedAccount(address)",
                user1
            )
        );
        token.setLimitCap(100 ether);
        vm.stopPrank();
    }

    function test_admin_can_set_minting_limit() public {
        test_owner_can_set_limit_cap();
        vm.startPrank(admin);
        token.setMintingLimit(system, 100 ether);
        vm.stopPrank();
        assertEq(token.mintingCurrentLimitOf(system), 100 ether);
    }

    function test_admin_cannot_set_minting_limit_above_limit_cap() public {
        test_owner_can_set_limit_cap();
        vm.startPrank(admin);
        vm.expectRevert(abi.encodeWithSignature("IXERC20_LimitsTooHigh()"));
        token.setMintingLimit(system, 250 ether);
        vm.stopPrank();
    }

    function test_non_admin_cannot_set_minting_limit() public {
        vm.expectRevert("SystemRole: caller is not an admin account");

        token.setMintingLimit(user1, 50 ether);
    }

    function test_system_account_can_mint_tokens() public {
        test_owner_can_set_limit_cap();
        test_admin_can_set_minting_limit();
        address user = vm.addr(userPrivateKey);
        vm.startPrank(system);
        token.mint(user, 100 ether);
        vm.stopPrank();

        assertEq(token.balanceOf(user), 100 ether);
    }

    function test_system_account_cannot_mint_tokens_above_minting_limit()
        public
    {
        test_owner_can_set_limit_cap();
        test_admin_can_set_minting_limit();
        address user = vm.addr(userPrivateKey);
        vm.startPrank(system);

        vm.expectRevert(
            abi.encodeWithSignature("IXERC20_NotHighEnoughLimits()")
        );
        token.mint(user, 101 ether);
        vm.stopPrank();
    }

    function test_non_system_account_cannot_mint_tokens() public {
        vm.expectRevert("SystemRole: caller is not a system account");
        token.mint(user1, 100 ether);
    }

    function test_system_account_can_burn_tokens() public {
        test_owner_can_set_limit_cap();
        test_admin_can_set_minting_limit();
        test_system_account_can_mint_tokens();

        address user = vm.addr(userPrivateKey);
        bytes32 hash = 0xb77c35c892a1b24b10a2ce49b424e578472333ee8d2456234fff90626332c50f;
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, hash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.startPrank(system);
        token.burn(user, 50 ether, hash, signature);
        vm.stopPrank();

        assertEq(token.balanceOf(user), 50 ether);
    }

    function test_non_system_account_cannot_burn_tokens() public {
        test_owner_can_set_limit_cap();
        test_admin_can_set_minting_limit();
        test_system_account_can_mint_tokens();

        address user = vm.addr(userPrivateKey);
        bytes32 hash = keccak256(
            "I hereby declare that I am the address owner."
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, hash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.expectRevert("SystemRole: caller is not a system account");
        token.burn(user, 50 ether, hash, signature);
    }

    function test_system_account_cannot_burn_tokens_with_invalid_signature()
        public
    {
        test_owner_can_set_limit_cap();
        test_admin_can_set_minting_limit();
        test_system_account_can_mint_tokens();

        address user = vm.addr(userPrivateKey);
        bytes32 hash2 = keccak256("Invalid burn");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, hash2);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.startPrank(system);
        vm.expectRevert("signature/hash does not match");
        token.burn(user, 50 ether, hash2, signature);
        vm.stopPrank();
    }

    function test_can_get_maxLimit() public {
        test_owner_can_set_limit_cap();

        vm.startPrank(admin);
        token.setMintingLimit(system, 100 ether);

        assertEq(
            token.mintingCurrentLimitOf(system),
            token.mintingMaxLimitOf(system)
        );
    }

    function test_changing_maxLimit_updates_current_limit() public {
        test_owner_can_set_limit_cap();
        vm.startPrank(admin);

        token.setMintingLimit(system, 100 ether);

        assertEq(token.mintingCurrentLimitOf(system), 100 ether);

        token.setMintingLimit(system, 50 ether);
        vm.stopPrank();

        assertEq(token.mintingCurrentLimitOf(system), 50 ether);
    }

    function test_changing_maxLimit_when_limit_is_used_updates_current_limit()
        public
    {
        test_owner_can_set_limit_cap();
        vm.prank(admin);
        token.setMintingLimit(system, 100 ether);

        assertEq(token.mintingCurrentLimitOf(system), 100 ether);

        address user = vm.addr(userPrivateKey);
        vm.prank(system);
        token.mint(user, 100 ether);

        assertEq(token.mintingCurrentLimitOf(system), 0);

        vm.prank(admin);
        token.setMintingLimit(system, 50 ether);

        assertEq(token.mintingCurrentLimitOf(system), 0);
    }

    function test_chaning_partial_maxLimit_updates_currentLimit_when_used()
        public
    {
        test_owner_can_set_limit_cap();

        vm.prank(admin);
        token.setMintingLimit(system, 100 ether);

        address user = vm.addr(userPrivateKey);
        vm.prank(system);
        token.mint(user, 10 ether);

        vm.prank(admin);
        token.setMintingLimit(system, 50 ether);

        assertEq(token.mintingCurrentLimitOf(system), 40 ether);
    }

    function test_chaning_partial_maxLimit_updates_currentLimit_whith_increase()
        public
    {
        test_owner_can_set_limit_cap();

        vm.prank(admin);
        token.setMintingLimit(system, 100 ether);

        address user = vm.addr(userPrivateKey);
        vm.prank(system);
        token.mint(user, 10 ether);

        vm.prank(admin);
        token.setMintingLimit(system, 120 ether);

        assertEq(token.mintingCurrentLimitOf(system), 110 ether);
    }

    function test_currentLimit_is_updated_with_time() public {
        test_owner_can_set_limit_cap();

        vm.prank(admin);
        token.setMintingLimit(system, 100 ether);

        address user = vm.addr(userPrivateKey);
        vm.prank(system);
        token.mint(user, 100 ether);

        vm.warp(block.timestamp + 12 hours);

        assertApproxEqRel(
            token.mintingCurrentLimitOf(system),
            100 ether / 2,
            0.1 ether
        );
    }

    function test_currentLimit_is_max_after_duration() public {
        test_owner_can_set_limit_cap();

        vm.prank(admin);
        token.setMintingLimit(system, 100 ether);

        address user = vm.addr(userPrivateKey);
        vm.prank(system);
        token.mint(user, 100 ether);

        vm.warp(block.timestamp + 25 hours);

        assertEq(token.mintingCurrentLimitOf(system), 100 ether);
    }

    function test_currentLimit_is_max_after_half_use_and_half_duration()
        public
    {
        test_owner_can_set_limit_cap();

        vm.prank(admin);
        token.setMintingLimit(system, 100 ether);

        address user = vm.addr(userPrivateKey);
        vm.prank(system);
        token.mint(user, 50 ether);

        vm.warp(block.timestamp + 12.1 hours);
        assertEq(token.mintingCurrentLimitOf(system), 100 ether);

    }

    function test_currentLimit_is_same_if_unused() public {
        test_owner_can_set_limit_cap();

        vm.prank(admin);
        token.setMintingLimit(system, 100 ether);

        vm.warp(block.timestamp + 12 hours);

        assertEq(token.mintingCurrentLimitOf(system), 100 ether);
    }

    function test_currentLimit_can_be_set() public {
        test_owner_can_set_limit_cap();

        vm.prank(admin);
        token.setMintingLimit(system, 100 ether);

        address user = vm.addr(userPrivateKey);
        vm.prank(system);
        token.mint(user, 100 ether);

        assertEq(token.mintingCurrentLimitOf(system), 0 ether);

        vm.prank(admin);
        token.setMintingCurrentLimit(system, 100 ether);

        assertEq(token.mintingCurrentLimitOf(system), 100 ether);
    }

    function test_currentLimit_can_be_set_regardless_of_time() public {
        test_owner_can_set_limit_cap();

        vm.prank(admin);
        token.setMintingLimit(system, 100 ether);

        address user = vm.addr(userPrivateKey);
        vm.prank(system);
        token.mint(user, 100 ether);

        assertEq(token.mintingCurrentLimitOf(system), 0 ether);

        vm.prank(admin);
        token.setMintingCurrentLimit(system, 100 ether);

        vm.warp(block.timestamp + 12 hours);

        assertEq(token.mintingCurrentLimitOf(system), 100 ether);
    }

    function test_currentLimit_can_be_set_above_minter_maxLimit_up_to_limitCap()
        public
    {
        test_owner_can_set_limit_cap();

        vm.prank(admin);
        token.setMintingLimit(system, 100 ether);

        address user = vm.addr(userPrivateKey);
        vm.prank(system);
        token.mint(user, 100 ether);

        assertEq(token.mintingCurrentLimitOf(system), 0 ether);

        uint256 cap = token.getLimitCap();
        vm.prank(admin);
        token.setMintingCurrentLimit(system, cap);

        assertEq(token.mintingCurrentLimitOf(system), cap);
    }

    function test_currentLimit_can_stay_higher_than_maxLimit_regardless_of_time()
        public
    {
        test_owner_can_set_limit_cap();

        vm.prank(admin);
        token.setMintingLimit(system, 100 ether);

        address user = vm.addr(userPrivateKey);
        vm.prank(system);
        token.mint(user, 100 ether);

        assertEq(token.mintingCurrentLimitOf(system), 0 ether);

        uint256 cap = token.getLimitCap();
        vm.prank(admin);
        token.setMintingCurrentLimit(system, cap);

        assertEq(token.mintingCurrentLimitOf(system), cap);

        vm.warp(block.timestamp + 25 hours);

        assertEq(token.mintingCurrentLimitOf(system), cap);
    }

    function test_currentLimit_canot_be_set_above_limitCap() public {
        test_owner_can_set_limit_cap();

        vm.prank(admin);
        token.setMintingLimit(system, 100 ether);

        address user = vm.addr(userPrivateKey);
        vm.prank(system);
        token.mint(user, 100 ether);

        assertEq(token.mintingCurrentLimitOf(system), 0 ether);

        uint256 cap = token.getLimitCap();

        vm.startPrank(admin);
        vm.expectRevert(abi.encodeWithSignature("IXERC20_LimitsTooHigh()"));
        token.setMintingCurrentLimit(system, cap + 0.1 ether);
        vm.stopPrank();
    }
}
