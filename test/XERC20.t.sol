// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Token.sol";
import "../src/BlacklistValidatorUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "forge-std/console.sol";
import "./Common.t.sol";

contract XERC20Test is Common {
    function test_setLockbox() public {
      vm.expectRevert("Not Implemented");
      token.setLockbox(system);
    }

    function test_mint() public {
        vm.prank(admin);
        token.setLimits(system, 100 ether, 0);

        assertEq(token.balanceOf(user1), 0);
        vm.prank(system);
        token.mint(user1, 100 ether);

        assertEq(token.balanceOf(user1), 100 ether);
    }

    function test_burn() public {
        vm.prank(admin);
        token.setLimits(system, 100 ether, 100 ether);

        vm.prank(system);
        token.mint(user1, 100 ether); // Minting to user

        vm.prank(user1);
        token.approve(system, 100 ether); // User approves system to burn

        vm.prank(system);
        token.burn(user1, 100 ether); // System performs the burn

        assertEq(token.balanceOf(user1), 0); // Asserting user's balance after burn
        assertEq(token.totalSupply(), 0); // Asserting total supply after burn
    }

    function test_change_limit() public {
        vm.prank(admin);
        token.setLimits(system, 100 ether, 100 ether);

        assertEq(token.mintingMaxLimitOf(system), 100 ether);
        assertEq(token.burningMaxLimitOf(system), 100 ether);
    }

    function test_adding_minters_and_limits() public {
        uint256[] memory limits = new uint256[](3);
        address[] memory minters = new address[](3);

        limits[0] = 100 ether;
        limits[1] = 100 ether;
        limits[2] = 100 ether;

        minters[0] = vm.addr(1);
        minters[1] = vm.addr(2);
        minters[2] = vm.addr(3);

        vm.startPrank(admin);
        for (uint256 i = 0; i < minters.length; i++) {
            token.setLimits(minters[i], limits[i], limits[i]);
        }
        vm.stopPrank();
        assertEq(token.mintingMaxLimitOf(vm.addr(1)), 100 ether);
        assertEq(token.mintingMaxLimitOf(vm.addr(2)), 100 ether);
        assertEq(token.mintingMaxLimitOf(vm.addr(3)), 100 ether);
    }

    function test_use_limits_updates_limit() public {
        vm.startPrank(admin);
        token.setLimits(system, 100 ether, 100 ether);
        vm.stopPrank();

        vm.prank(user1);
        token.approve(system, 100 ether);

        vm.startPrank(system);
        token.mint(user1, 100 ether);
        token.burn(user1, 100 ether);
        vm.stopPrank();

        assertEq(token.mintingCurrentLimitOf(system), 0);
        assertEq(token.burningCurrentLimitOf(system), 0);
    }

    function test_changing_max_limit_updates_current_limit() public {
        vm.startPrank(admin);
        token.setLimits(system, 100 ether, 100 ether);
        vm.stopPrank();

        vm.startPrank(admin);
        token.setLimits(system, 50 ether, 50 ether);
        vm.stopPrank();

        assertEq(token.mintingCurrentLimitOf(system), 50 ether);
        assertEq(token.burningCurrentLimitOf(system), 50 ether);
    }

    function test_changing_max_limit_when_limit_is_used_updates_current_limit()
        public
    {
        vm.startPrank(admin);
        token.setLimits(system, 100 ether, 100 ether);
        vm.stopPrank();

        vm.prank(user1);
        token.approve(system, 100 ether);

        vm.startPrank(system);
        token.mint(user1, 100 ether);
        token.burn(user1, 100 ether);
        vm.stopPrank();

        vm.startPrank(admin);
        token.setLimits(system, 50 ether, 50 ether);
        vm.stopPrank();

        assertEq(token.mintingCurrentLimitOf(system), 0);
        assertEq(token.burningCurrentLimitOf(system), 0);
    }

    function test_changing_partial_max_limit_updates_current_limit_when_used()
        public
    {
        vm.startPrank(admin);
        token.setLimits(system, 100 ether, 100 ether);
        vm.stopPrank();

        vm.prank(user1);
        token.approve(system, 100 ether);

        vm.startPrank(system);
        token.mint(user1, 10 ether);
        token.burn(user1, 10 ether);
        vm.stopPrank();

        vm.startPrank(admin);
        token.setLimits(system, 50 ether, 50 ether);
        vm.stopPrank();

        assertEq(token.mintingCurrentLimitOf(system), 40 ether); // Reflects remaining limit after usage
        assertEq(token.burningCurrentLimitOf(system), 40 ether); // Reflects remaining limit after usage
    }

    function test_changing_partial_max_limit_updates_current_limit_with_increase()
        public
    {
        vm.startPrank(admin);
        token.setLimits(system, 100 ether, 100 ether);
        vm.stopPrank();

        vm.prank(user1);
        token.approve(system, 100 ether);

        vm.startPrank(system);
        token.mint(user1, 10 ether);
        token.burn(user1, 10 ether);
        vm.stopPrank();

        vm.startPrank(admin);
        token.setLimits(system, 120 ether, 120 ether);
        vm.stopPrank();

        assertEq(token.mintingCurrentLimitOf(system), 110 ether); // Updated limit plus remaining from previous
        assertEq(token.burningCurrentLimitOf(system), 110 ether); // Updated limit plus remaining from previous
    }

    function test_current_limit_is_updated_with_time() public {
        vm.startPrank(admin);
        token.setLimits(system, 100 ether, 100 ether);
        vm.stopPrank();

        vm.prank(user1);
        token.approve(system, 100 ether);

        vm.prank(user1);
        token.approve(system, 100 ether);

        vm.startPrank(system);
        token.mint(user1, 100 ether);
        token.burn(user1, 100 ether);
        vm.stopPrank();

        // Move block.timestamp forward 12 hours
        vm.warp(block.timestamp + 12 hours);

        assertApproxEqRel(
            token.mintingCurrentLimitOf(system),
            100 ether / 2,
            0.1 ether
        ); // Checks half of limit after time warp
        assertApproxEqRel(
            token.burningCurrentLimitOf(system),
            100 ether / 2,
            0.1 ether
        ); // Checks half of limit after time warp
    }

    function test_current_limit_is_max_after_duration() public {
        vm.startPrank(admin);
        token.setLimits(system, 100 ether, 100 ether);
        vm.stopPrank();

        vm.prank(user1);
        token.approve(system, 100 ether);

        vm.startPrank(system);
        token.mint(user1, 100 ether);
        token.burn(user1, 100 ether);
        vm.stopPrank();

        // Move block.timestamp forward 25 hours
        vm.warp(block.timestamp + 25 hours);

        assertEq(token.mintingCurrentLimitOf(system), 100 ether); // Check if limit is fully restored
        assertEq(token.burningCurrentLimitOf(system), 100 ether); // Check if limit is fully restored
    }

    function test_current_limit_is_same_if_unused() public {
        vm.startPrank(admin);
        token.setLimits(system, 100 ether, 100 ether);
        vm.stopPrank();

        // Move block.timestamp forward 12 hours
        vm.warp(block.timestamp + 12 hours);

        assertEq(token.mintingCurrentLimitOf(system), 100 ether); // Confirm limit remains full if unused
        assertEq(token.burningCurrentLimitOf(system), 100 ether); // Confirm limit remains full if unused
    }

    function test_currentLimit_can_be_set_for_burning() public {
        vm.prank(admin);
        token.setLimits(system, 100 ether, 100 ether);

        address user = vm.addr(1);

        vm.prank(user);
        token.approve(system, 100 ether);

        vm.startPrank(system);
        token.mint(user, 100 ether);
        token.burn(user, 100 ether);
        vm.stopPrank();

        assertEq(token.burningCurrentLimitOf(system), 0 ether);

        vm.prank(admin);
        token.setBurningCurrentLimit(system, 100 ether);

        assertEq(token.burningCurrentLimitOf(system), 100 ether);
    }

    function test_currentLimit_for_burning_can_be_set_regardless_of_time()
        public
    {
        vm.prank(admin);
        token.setLimits(system, 100 ether, 100 ether);

        address user = vm.addr(1);

        vm.prank(user);
        token.approve(system, 100 ether);

        vm.startPrank(system);
        token.mint(user, 100 ether);
        token.burn(user, 100 ether);
        vm.stopPrank();

        assertEq(token.burningCurrentLimitOf(system), 0 ether);

        vm.prank(admin);
        token.setBurningCurrentLimit(system, 100 ether);

        vm.warp(block.timestamp + 12 hours);

        assertEq(token.burningCurrentLimitOf(system), 100 ether);
    }

    function test_currentLimit_for_burning_can_be_set_above_minter_maxLimit_up_to_limitCap()
        public
    {
        vm.prank(admin);
        token.setLimits(system, 100 ether, 100 ether);

        address user = vm.addr(1);

        vm.prank(user);
        token.approve(system, 100 ether);

        vm.startPrank(system);
        token.mint(user, 100 ether);
        token.burn(user, 100 ether);
        vm.stopPrank();

        assertEq(token.burningCurrentLimitOf(system), 0 ether);

        uint256 cap = token.getLimitCap();
        vm.prank(admin);
        token.setBurningCurrentLimit(system, cap);

        assertEq(token.burningCurrentLimitOf(system), cap);
    }

    function test_currentLimit_for_burning_can_stay_higher_than_maxLimit_regardless_of_time()
        public
    {
        vm.prank(admin);
        token.setLimits(system, 100 ether, 100 ether);

        address user = vm.addr(1);

        vm.prank(user);
        token.approve(system, 100 ether);

        vm.startPrank(system);
        token.mint(user, 100 ether);
        token.burn(user, 100 ether);
        vm.stopPrank();

        assertEq(token.burningCurrentLimitOf(system), 0 ether);

        uint256 cap = token.getLimitCap();
        vm.prank(admin);
        token.setBurningCurrentLimit(system, cap);

        assertEq(token.burningCurrentLimitOf(system), cap);

        vm.warp(block.timestamp + 25 hours);

        assertEq(token.burningCurrentLimitOf(system), cap);
    }

    function test_useMinterLimits_sufficientLimit() public {
        address user = vm.addr(1);
        uint256 setLimit = 100 ether;
        uint256 mintAmount = 50 ether;

        // Admin sets the minting limit
        vm.prank(admin);
        token.setMintingLimit(system, setLimit);

        // User mints within the limit
        vm.prank(system);
        token.mint(user, mintAmount);

        // Check the current limit after minting
        uint256 expectedCurrentLimit = setLimit - mintAmount;
        assertEq(
            token.mintingCurrentLimitOf(system),
            expectedCurrentLimit,
            "Current limit should be reduced by the minted amount"
        );
    }

    function test_useMinterLimits_insufficientLimit() public {
        address user = vm.addr(1);
        uint256 setLimit = 100 ether;
        uint256 mintAmount = 150 ether;

        // Admin sets the minting limit
        vm.prank(admin);
        token.setMintingLimit(user, setLimit);

        // User tries to mint above the limit, expecting a revert
        vm.prank(system);
        vm.expectRevert(abi.encodeWithSignature("IXERC20_NotHighEnoughLimits()"));
        token.mint(user, mintAmount);
    }
    function test_currentLimit_for_burning_cannot_be_set_above_limitCap()
        public
    {
        vm.prank(admin);
        token.setLimits(system, 100 ether, 100 ether);

        address user = vm.addr(1);

        vm.prank(user);
        token.approve(system, 100 ether);

        vm.startPrank(system);
        token.mint(user, 100 ether);
        token.burn(user, 100 ether);
        vm.stopPrank();

        assertEq(token.burningCurrentLimitOf(system), 0 ether);

        uint256 cap = token.getLimitCap();

        vm.startPrank(admin);
        vm.expectRevert(abi.encodeWithSignature("IXERC20_LimitsTooHigh()"));
        token.setBurningCurrentLimit(system, cap + 0.1 ether);
        vm.stopPrank();
    }
    function test_multiple_users_use_bridge() public {
        address user0 = vm.addr(1);
        address user1 = vm.addr(2);
        address user2 = vm.addr(3);
        address user3 = vm.addr(4);
        address user4 = vm.addr(5);

        vm.startPrank(admin);
        token.setLimits(system, 100 ether, 100 ether);
        vm.stopPrank();

        vm.startPrank(system);
        token.mint(user0, 10 ether);
        token.mint(user1, 10 ether);
        token.mint(user2, 10 ether);
        token.mint(user3, 10 ether);
        token.mint(user4, 10 ether);
        vm.stopPrank();

        assertEq(token.mintingCurrentLimitOf(system), 50 ether); // Check the remaining limit after multiple mints

        vm.warp(block.timestamp + 12 hours);

        assertApproxEqRel(
            token.mintingCurrentLimitOf(system),
            50 ether + (100 ether / 2),
            0.1 ether
        ); // Check the regenerated limit after time warp
    }

    function test_multiple_mints_and_burns() public {
        address user0 = vm.addr(1);
        address user1 = vm.addr(2);
        address user2 = vm.addr(3);
        address user3 = vm.addr(4);
        address user4 = vm.addr(5);

        vm.startPrank(admin);
        token.setLimits(system, 100 ether, 100 ether);
        vm.stopPrank();

        vm.startPrank(system);
        token.mint(user0, 20 ether);
        token.mint(user1, 10 ether);
        token.mint(user2, 20 ether);
        token.mint(user3, 10 ether);
        token.mint(user4, 20 ether);
        vm.stopPrank();

        assertEq(token.mintingCurrentLimitOf(system), 20 ether); // Remaining minting limit after several mints

        vm.prank(user0);
        token.approve(system, 100 ether);

        vm.prank(user1);
        token.approve(system, 100 ether);

        vm.prank(user2);
        token.approve(system, 100 ether);

        vm.prank(user3);
        token.approve(system, 100 ether);

        vm.prank(user4);
        token.approve(system, 100 ether);

        vm.startPrank(system);
        token.burn(user0, 5 ether);
        token.burn(user1, 5 ether);
        token.burn(user2, 5 ether);
        token.burn(user3, 5 ether);
        token.burn(user4, 5 ether);
        vm.stopPrank();

        assertEq(token.burningCurrentLimitOf(system), 75 ether); // Remaining burning limit after several burns

        vm.warp(block.timestamp + 12 hours);

        assertApproxEqRel(
            token.mintingCurrentLimitOf(system),
            20 ether + (100 ether / 2),
            0.1 ether
        ); // Check regenerated minting limit after time warp
        assertEq(token.burningCurrentLimitOf(system), 100 ether); // Burning limit restored to max after time warp
    }

    function test_multiple_bridges_have_different_value() public {
        address user = vm.addr(1);
        uint256 systemLimit = 100 ether;
        uint256 userLimit = 50 ether;

        token.addSystemAccount(user);

        vm.startPrank(admin);
        token.setLimits(system, systemLimit, systemLimit);
        token.setLimits(user, userLimit, userLimit);
        vm.stopPrank();

        vm.prank(user);
        token.approve(system, 100 ether);

        vm.prank(system);
        token.approve(user, 100 ether);

        vm.startPrank(system);
        token.mint(user, 90 ether);
        token.burn(user, 90 ether);
        vm.stopPrank();

        vm.startPrank(user);
        token.mint(system, 40 ether);
        token.burn(system, 40 ether);
        vm.stopPrank();

        uint256 minterMaxLimitOwner = token.mintingMaxLimitOf(system);
        uint256 minterMaxLimitUser = token.mintingMaxLimitOf(user);

        uint256 minterCurrentLimitOwner = token.mintingCurrentLimitOf(system);
        uint256 minterCurrentLimitUser = token.mintingCurrentLimitOf(user);

        assertEq(minterMaxLimitOwner, systemLimit);
        assertEq(minterCurrentLimitOwner, systemLimit - 90 ether);
        assertEq(minterMaxLimitUser, userLimit);
        assertEq(minterCurrentLimitUser, userLimit - 40 ether);

        vm.warp(block.timestamp + 12 hours);

        assertApproxEqRel(
            token.mintingCurrentLimitOf(system),
            systemLimit - 90 ether + (systemLimit / 2),
            0.1 ether
        );
        assertApproxEqRel(
            token.mintingCurrentLimitOf(user),
            userLimit - 40 ether + (userLimit / 2),
            0.1 ether
        );

        assertApproxEqRel(
            token.burningCurrentLimitOf(system),
            systemLimit - 90 ether + (systemLimit / 2),
            0.1 ether
        );
        assertApproxEqRel(
            token.burningCurrentLimitOf(user),
            userLimit - 40 ether + (userLimit / 2),
            0.1 ether
        );
    }

    function test_multiple_bridges_burns_have_different_values() public {
        address user = vm.addr(1);
        uint256 ownerLimit = 100 ether;
        uint256 userLimit = 50 ether;

        token.addSystemAccount(user);

        vm.prank(user);
        token.approve(system, 100 ether);

        vm.prank(system);
        token.approve(user, 100 ether);

        vm.startPrank(admin);
        token.setLimits(system, ownerLimit, ownerLimit);
        token.setLimits(user, userLimit, userLimit);
        vm.stopPrank();

        vm.startPrank(system);
        token.mint(user, 90 ether);
        token.burn(user, 50 ether);
        vm.stopPrank();

        vm.startPrank(user);
        token.mint(system, 40 ether);
        token.burn(system, 25 ether);
        vm.stopPrank();

        uint256 burnerMaxLimitOwner = token.burningMaxLimitOf(system);
        uint256 burnerMaxLimitUser = token.burningMaxLimitOf(user);

        uint256 burnerCurrentLimitOwner = token.burningCurrentLimitOf(system);
        uint256 burnerCurrentLimitUser = token.burningCurrentLimitOf(user);

        assertEq(burnerMaxLimitOwner, ownerLimit);
        assertEq(burnerCurrentLimitOwner, ownerLimit - 50 ether);
        assertEq(burnerMaxLimitUser, userLimit);
        assertEq(burnerCurrentLimitUser, userLimit - 25 ether);

        vm.warp(block.timestamp + 12 hours);

        assertApproxEqRel(
            token.mintingCurrentLimitOf(system),
            ownerLimit - 90 ether + (ownerLimit / 2),
            0.1 ether
        );
        assertApproxEqRel(
            token.mintingCurrentLimitOf(user),
            userLimit - 40 ether + (userLimit / 2),
            0.1 ether
        );

        assertApproxEqRel(
            token.burningCurrentLimitOf(system),
            ownerLimit - 50 ether + (ownerLimit / 2),
            0.1 ether
        );
        assertApproxEqRel(
            token.burningCurrentLimitOf(user),
            userLimit - 25 ether + (userLimit / 2),
            0.1 ether
        );
    }
}

