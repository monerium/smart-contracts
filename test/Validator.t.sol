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
        validator.setV1Frontend(frontend);
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

    function testFrontendRole() public {
        assertTrue(validator.isV1Frontend(frontend));
        vm.prank(admin);
        validator.revokeV1Frontend(frontend);
        assertFalse(validator.isV1Frontend(frontend));
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
        // Direct validator calls (isolated testing, not realistic)
        // Not blocked or blacklisted
        vm.prank(user);
        assertTrue(validator.validate(user, admin, 100));

        // These tests show validator WOULD work if called directly from frontend
        // but this is NOT how it works in production
        vm.prank(frontend);
        vm.expectRevert(abi.encodeWithSelector(Validator.V1Blocked.selector, blocked));
        validator.validate(blocked, admin, 100);

        vm.prank(frontend);
        vm.expectRevert(abi.encodeWithSelector(Validator.V1Blocked.selector, blocked));
        validator.validate(admin, blocked, 100);

        // Blacklisted always reverts
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
    function testIsV1Frontend() public {
        assertTrue(validator.isV1Frontend(frontend));
        assertFalse(validator.isV1Frontend(address(0xdead)));
    }

    /**
     * @notice Tests that V1 frontend rejects transfers from V1_BLOCKED addresses
     * @dev When V1 frontend calls transfer_withCaller() with a blocked address,
     *      the validator should detect it's a V1 frontend call and revert.
     *
     *      Call chain: frontend -> ControllerToken.transfer_withCaller() -> validator.validate()
     *
     *      Expected behavior:
     *      - validator.validate() receives msg.sender = frontend (marked as V1_FRONTEND_ROLE)
     *      - validator checks isV1Frontend(msg.sender) = true
     *      - validator checks isV1Blocked(from) = true
     *      - validator reverts with "blocked in V1"
     *
     *      Current behavior:
     *      - validator.validate() receives msg.sender = ControllerToken (NOT frontend)
     *      - validator checks isV1Frontend(msg.sender) = false
     *      - V1_BLOCKED check is skipped
     *      - Transfer succeeds
     */
    function testV1FrontendBlocksV1BlockedAddresses() public {
        // V1 frontend attempts to transfer from a V1_BLOCKED address
        vm.prank(frontend);
        vm.expectRevert(abi.encodeWithSelector(Validator.V1Blocked.selector, blocked));
        token.transfer_withCaller(blocked, user, 100 ether);
    }

    /**
     * @notice Tests that V1 frontend rejects transfers from blacklisted addresses
     * @dev Blacklist check should work regardless of whether call comes from V1 frontend or V2 direct.
     *      The blacklist check doesn't depend on msg.sender, it always checks both from and to addresses.
     */
    function testV1FrontendBlocksBlacklistedFrom() public {
        // V1 frontend attempts to transfer from a blacklisted address
        vm.prank(frontend);
        vm.expectRevert(abi.encodeWithSelector(Validator.Blacklisted.selector, blacklisted));
        token.transfer_withCaller(blacklisted, user, 100 ether);
    }

    /**
     * @notice Tests that V1 frontend rejects transfers to blacklisted addresses
     */
    function testV1FrontendBlocksBlacklistedTo() public {
        // V1 frontend attempts to transfer to a blacklisted address
        vm.prank(frontend);
        vm.expectRevert(abi.encodeWithSelector(Validator.Blacklisted.selector, blacklisted));
        token.transfer_withCaller(user, blacklisted, 100 ether);
    }

    /**
     * @notice Tests that V1 frontend allows transfers for non-blocked, non-blacklisted addresses
     */
    function testV1FrontendAllowsNormalTransfers() public {
        // V1 frontend transfers from normal user should succeed
        vm.prank(frontend);
        token.transfer_withCaller(user, admin, 100 ether);
        assertEq(token.balanceOf(admin), 100 ether);
    }

    /**
     * @notice Tests gas optimization: when no V1_BLOCKED addresses exist, validation is cheaper
     * @dev This simulates Arbitrum and other chains without V1 frontends
     */
    function testGasOptimizationNoBlockedAddresses() public {
        // Deploy a new validator with no blocked addresses
        vm.startPrank(owner);
        Validator gasOptimizedValidator = new Validator();

        // Deploy new token with the gas-optimized validator
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

        gasOptimizedValidator.setAdmin(admin);
        vm.stopPrank();

        vm.prank(admin);
        gasOptimizedValidator.setV1Frontend(frontend);

        // Verify no blocked addresses
        assertEq(gasOptimizedValidator.getV1BlockedCount(), 0);

        // Transfer should succeed and be cheaper (skips getFrontend() call)
        vm.prank(frontend);
        gasToken.transfer_withCaller(user, admin, 100 ether);
        assertEq(gasToken.balanceOf(admin), 100 ether);
    }

    /**
     * @notice Tests that V1_BLOCKED counter increments and decrements correctly
     */
    function testV1BlockedCounter() public {
        assertEq(validator.getV1BlockedCount(), 1, "Should have 1 blocked address from setup");

        // Add another blocked address
        vm.prank(admin);
        validator.setV1Blocked(address(0x999));
        assertEq(validator.getV1BlockedCount(), 2);

        // Remove original blocked address
        vm.prank(admin);
        validator.revokeV1Blocked(blocked);
        assertEq(validator.getV1BlockedCount(), 1);

        // Remove second blocked address
        vm.prank(admin);
        validator.revokeV1Blocked(address(0x999));
        assertEq(validator.getV1BlockedCount(), 0);

        // Adding same address multiple times shouldn't increment counter
        vm.startPrank(admin);
        validator.setV1Blocked(blocked);
        assertEq(validator.getV1BlockedCount(), 1);
        validator.setV1Blocked(blocked); // Same address again
        assertEq(validator.getV1BlockedCount(), 1, "Counter should not increment for duplicate");
        vm.stopPrank();
    }
}