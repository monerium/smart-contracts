// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Validator.sol";

contract ValidatorTest is Test {
    Validator validator;
    address owner = address(0x1);
    address admin = address(0x2);
    address user = address(0x3);
    address blocked = address(0x4);
    address blacklisted = address(0x5);
    address frontend = address(0x6);

    function setUp() public {
        vm.prank(owner);
        validator = new Validator();

        // Grant roles for testing
        vm.prank(owner);
        validator.setAdmin(admin);

        vm.prank(admin);
        validator.setV1Blocked(blocked);

        vm.prank(admin);
        validator.setBlacklisted(blacklisted);

        vm.prank(admin);
        validator.setV1Frontend(frontend);
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
        // Not blocked or blacklisted
        vm.prank(user);
        assertTrue(validator.validate(user, admin, 100));

        // Blocked by frontend
        vm.prank(frontend);
        assertFalse(validator.validate(blocked, admin, 100));
        vm.prank(frontend);
        assertFalse(validator.validate(admin, blocked, 100));

        // Blacklisted always fails
        vm.prank(user);
        assertFalse(validator.validate(blacklisted, admin, 100));
        vm.prank(user);
        assertFalse(validator.validate(admin, blacklisted, 100));
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
}