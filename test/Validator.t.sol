// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Validator.sol";
import "../src/ControllerToken.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract ValidatorTest is Test {
    Validator validator;
    ControllerToken token;
    address owner = address(0x1);
    address admin = address(0x2);
    address user = address(0x3);
    address blocked = address(0x4);
    address blacklisted = address(0x5);
    address frontend = address(0x6);

    function setUp() public {
        vm.startPrank(owner);

        // Deploy Validator
        validator = new Validator();

        // Deploy ControllerToken with proxy for integration testing
        ControllerToken implementation = new ControllerToken();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeWithSelector(
                ControllerToken.initialize.selector,
                "Test Token",
                "TEST",
                bytes3("TST"),
                address(validator)
            )
        );
        token = ControllerToken(address(proxy));

        // Setup token
        token.setFrontend(frontend);
        token.addAdminAccount(owner);
        token.addSystemAccount(owner);
        token.setMaxMintAllowance(type(uint256).max);
        token.setMintAllowance(owner, type(uint256).max);

        // Setup validator roles
        validator.setAdmin(admin);
        vm.stopPrank();

        vm.startPrank(admin);
        validator.setV1Blocked(blocked);
        validator.setBlacklisted(blacklisted);
        vm.stopPrank();

        // Mint tokens to test addresses
        vm.prank(owner);
        token.mint(user, 1000 ether);
        vm.prank(owner);
        token.mint(blocked, 1000 ether);
        vm.prank(owner);
        token.mint(blacklisted, 1000 ether);
    }

    function testAdminRole() public {
        assertTrue(validator.isAdminAccount(admin));
        vm.prank(owner);
        validator.revokeAdmin(admin);
        assertFalse(validator.isAdminAccount(admin));
    }

    function testBlockedRole() public {
        assertTrue(validator.isV1Blocked(blocked));
        vm.prank(admin);
        validator.revokeV1Blocked(blocked);
        assertFalse(validator.isV1Blocked(blocked));
    }

    function testBlacklistedRole() public {
        assertTrue(validator.isBlacklisted(blacklisted));
        vm.prank(admin);
        validator.revokeBlacklisted(blacklisted);
        assertFalse(validator.isBlacklisted(blacklisted));
    }

    function testValidateTransfer() public {
        // Not blocked or blacklisted - should succeed
        vm.prank(user);
        token.transfer(admin, 100 ether);
        assertEq(token.balanceOf(admin), 100 ether);

        // Blacklisted always reverts (works correctly)
        vm.prank(blacklisted);
        vm.expectRevert(abi.encodeWithSelector(Validator.Blacklisted.selector, blacklisted));
        token.transfer(admin, 100 ether);

        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(Validator.Blacklisted.selector, blacklisted));
        token.transfer(blacklisted, 100 ether);
    }

    function testValidateTransferDirect() public {
        // Direct validate() calls only check the blacklist — V1 block is enforced at the
        // ControllerToken layer, not in validate() itself.
        vm.prank(user);
        assertTrue(validator.validate(user, admin, 100));

        // V1-blocked addresses are not blocked by validate() directly
        vm.prank(frontend);
        assertTrue(validator.validate(blocked, admin, 100));

        vm.prank(frontend);
        assertTrue(validator.validate(admin, blocked, 100));

        // Blacklisted always reverts regardless of caller
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(Validator.Blacklisted.selector, blacklisted));
        validator.validate(blacklisted, admin, 100);

        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(Validator.Blacklisted.selector, blacklisted));
        validator.validate(admin, blacklisted, 100);
    }

    function testContractId() public {
        bytes32 expected = 0x5341d189213c4172d0c7256f80bc5f8e6350af3aaff7a029625d8dd94f0f82a5;
        assertEq(validator.CONTRACT_ID(), expected);
    }

    function testIsAdminAccount() public {
        assertFalse(validator.isAdminAccount(owner));
        assertTrue(validator.isAdminAccount(admin));
        assertFalse(validator.isAdminAccount(address(0xdead)));
    }
    function testIsV1Blocked() public {
        assertTrue(validator.isV1Blocked(blocked));
        assertFalse(validator.isV1Blocked(address(0xdead)));
    }
    function testIsBlacklisted() public {
        assertTrue(validator.isBlacklisted(blacklisted));
        assertFalse(validator.isBlacklisted(address(0xdead)));
    }

    /**
     * @notice Tests that V1 frontend rejects transfers from V1_BLOCKED addresses.
     *         The check is enforced at the ControllerToken layer in transfer_withCaller,
     *         which is the exclusive V1 entrypoint. validate() is not involved.
     *
     *         Call chain: frontend -> ControllerToken.transfer_withCaller() -> V1Blocked revert
     */
    function testV1FrontendBlocksV1BlockedAddresses() public {
        vm.prank(frontend);
        vm.expectRevert(abi.encodeWithSelector(ControllerToken.V1Blocked.selector, blocked));
        token.transfer_withCaller(blocked, user, 100 ether);
    }

    /**
     * @notice Tests that V1 frontend rejects transfers from blacklisted addresses.
     */
    function testV1FrontendBlocksBlacklistedFrom() public {
        vm.prank(frontend);
        vm.expectRevert(abi.encodeWithSelector(Validator.Blacklisted.selector, blacklisted));
        token.transfer_withCaller(blacklisted, user, 100 ether);
    }

    /**
     * @notice Tests that V1 frontend rejects transfers to blacklisted addresses.
     */
    function testV1FrontendBlocksBlacklistedTo() public {
        vm.prank(frontend);
        vm.expectRevert(abi.encodeWithSelector(Validator.Blacklisted.selector, blacklisted));
        token.transfer_withCaller(user, blacklisted, 100 ether);
    }

    /**
     * @notice Tests that V1 frontend allows transfers for non-blocked, non-blacklisted addresses.
     */
    function testV1FrontendAllowsNormalTransfers() public {
        vm.prank(frontend);
        token.transfer_withCaller(user, admin, 100 ether);
        assertEq(token.balanceOf(admin), 100 ether);
    }

    /**
     * @notice A V1-blocked account can still transfer directly on V2.
     *         V1_BLOCKED_ROLE only restricts access via the V1 frontend (_withCaller path).
     */
    function test_v1BlockedAccount_canTransferOnV2Directly() public {
        vm.prank(blocked);
        token.transfer(user, 100 ether);
        assertEq(token.balanceOf(user), 1100 ether);
    }

    /**
     * @notice Gas optimization: ControllerToken skips isV1Blocked calls when v1BlockedCount is zero.
     *         This simulates Arbitrum and other chains without V1 frontends.
     */
    function testGasOptimizationNoBlockedAddresses() public {
        vm.startPrank(owner);
        Validator gasOptimizedValidator = new Validator();

        ControllerToken implementation = new ControllerToken();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeWithSelector(
                ControllerToken.initialize.selector,
                "Gas Test Token",
                "GTT",
                bytes3("GTT"),
                address(gasOptimizedValidator)
            )
        );
        ControllerToken gasToken = ControllerToken(address(proxy));

        gasToken.setFrontend(frontend);
        gasToken.addAdminAccount(owner);
        gasToken.addSystemAccount(owner);
        gasToken.setMaxMintAllowance(type(uint256).max);
        gasToken.setMintAllowance(owner, type(uint256).max);
        gasToken.mint(user, 1000 ether);
        vm.stopPrank();

        // Verify no blocked addresses — ControllerToken will skip isV1Blocked calls
        assertEq(gasOptimizedValidator.getV1BlockedCount(), 0);

        vm.prank(frontend);
        gasToken.transfer_withCaller(user, admin, 100 ether);
        assertEq(gasToken.balanceOf(admin), 100 ether);
    }

    // --- Ackee audit findings ---

    /**
     * @notice A blacklisted user cannot call renounceRole to remove their own blacklist entry.
     */
    function test_blacklistedUser_cannotRenounceOwnBlacklistRole() public {
        assertTrue(validator.isBlacklisted(blacklisted));
        bytes32 role = validator.BLACKLISTED_ROLE();

        vm.prank(blacklisted);
        vm.expectRevert(Validator.RenounceRoleNotAllowed.selector);
        validator.renounceRole(role, blacklisted);

        assertTrue(validator.isBlacklisted(blacklisted));
    }

    /**
     * @notice A V1-blocked user cannot call renounceRole to remove their own V1_BLOCKED_ROLE entry.
     */
    function test_v1BlockedUser_cannotRenounceOwnV1BlockedRole() public {
        assertTrue(validator.isV1Blocked(blocked));
        bytes32 role = validator.V1_BLOCKED_ROLE();

        vm.prank(blocked);
        vm.expectRevert(Validator.RenounceRoleNotAllowed.selector);
        validator.renounceRole(role, blocked);

        assertTrue(validator.isV1Blocked(blocked));
    }

    /**
     * @notice End-to-end: renounce reverts, transfer still blocked.
     */
    function test_blacklistedUser_cannotBypassBlacklistViaRenounce() public {
        assertTrue(validator.isBlacklisted(blacklisted));
        bytes32 role = validator.BLACKLISTED_ROLE();

        vm.prank(blacklisted);
        vm.expectRevert(Validator.RenounceRoleNotAllowed.selector);
        validator.renounceRole(role, blacklisted);

        vm.prank(blacklisted);
        vm.expectRevert(abi.encodeWithSelector(Validator.Blacklisted.selector, blacklisted));
        token.transfer(user, 1 ether);
    }

    /**
     * @notice Direct grantRole(V1_BLOCKED_ROLE) reverts; v1BlockedCount stays correct.
     */
    function test_directGrantRole_V1Blocked_isBlocked() public {
        uint256 countBefore = validator.getV1BlockedCount();
        bytes32 role = validator.V1_BLOCKED_ROLE();

        vm.prank(admin);
        vm.expectRevert(Validator.UseValidatorRoleFunctions.selector);
        validator.grantRole(role, address(0x999));

        assertEq(validator.getV1BlockedCount(), countBefore);
    }

    /**
     * @notice Direct revokeRole(V1_BLOCKED_ROLE) reverts; v1BlockedCount stays correct.
     */
    function test_directRevokeRole_V1Blocked_isBlocked() public {
        uint256 countBefore = validator.getV1BlockedCount();
        bytes32 role = validator.V1_BLOCKED_ROLE();

        vm.prank(admin);
        vm.expectRevert(Validator.UseValidatorRoleFunctions.selector);
        validator.revokeRole(role, blocked);

        assertEq(validator.getV1BlockedCount(), countBefore);
    }

    /**
     * @notice V1_BLOCKED counter increments and decrements correctly.
     */
    function testV1BlockedCounter() public {
        assertEq(validator.getV1BlockedCount(), 1, "Should have 1 blocked address from setup");

        vm.prank(admin);
        validator.setV1Blocked(address(0x999));
        assertEq(validator.getV1BlockedCount(), 2);

        vm.prank(admin);
        validator.revokeV1Blocked(blocked);
        assertEq(validator.getV1BlockedCount(), 1);

        vm.prank(admin);
        validator.revokeV1Blocked(address(0x999));
        assertEq(validator.getV1BlockedCount(), 0);

        vm.startPrank(admin);
        validator.setV1Blocked(blocked);
        assertEq(validator.getV1BlockedCount(), 1);
        validator.setV1Blocked(blocked);
        assertEq(validator.getV1BlockedCount(), 1, "Counter should not increment for duplicate");
        vm.stopPrank();
    }
}
