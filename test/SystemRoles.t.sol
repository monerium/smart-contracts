// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Token.sol";
import "../src/BlacklistValidatorUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "forge-std/console.sol";

//import "forge-std/Vm.sol";

contract SystemRoleTokenTest is Test {
    Token public token;
    ERC1967Proxy public proxy;

    address owner = address(this);
    address user1 = vm.addr(1);
    address user2 = vm.addr(2);
    address user3 = vm.addr(3);

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

        assertEq(token.name(), "token");
        assertEq(token.owner(), address(this));
    }

    function test_owner_should_be_able_to_add_system_account() public {
        token.addSystemAccount(user1);
        assertTrue(token.isSystemAccount(user1));
    }

    function test_owner_should_be_able_to_remove_system_account() public {
        token.addSystemAccount(user1);
        assertTrue(token.isSystemAccount(user1));
        token.removeSystemAccount(user1);
        assertTrue(!token.isSystemAccount(user1));
    }

    function test_owner_should_be_able_to_add_admin_account() public {
        token.addAdminAccount(user1);
        assertTrue(token.isAdminAccount(user1));
    }

    function test_owner_should_be_able_to_remove_admin_account() public {
        token.addAdminAccount(user1);
        assertTrue(token.isAdminAccount(user1));
        token.removeAdminAccount(user1);
        assertTrue(!token.isAdminAccount(user1));
    }

    function test_should_be_able_to_transfer_ownership() public {
        token.transferOwnership(user1);

        assertEq(token.pendingOwner(), user1);
    }

    function test_should_be_able_to_accept_ownership() public {
        test_should_be_able_to_transfer_ownership();
        vm.startPrank(user1);
        token.acceptOwnership();

        assertEq(token.owner(), user1);
    }
}
