// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Token.sol";
import "../src/BlacklistValidatorUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "forge-std/console.sol";

contract ERC20TokenTest is Test {
    Token public token;
    ERC1967Proxy public proxy;

    address owner = address(this);
    address system = vm.addr(1);
    address admin = vm.addr(2);
    address user1 = vm.addr(3);
    address user2 = vm.addr(4);
    bytes32 PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

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

        assertEq(token.owner(), owner);

        token.addSystemAccount(system);
        token.addAdminAccount(admin);
        assertTrue(token.isSystemAccount(system));
        assertTrue(token.isAdminAccount(admin));
        token.setMaxMintAllowance(100e18);
        vm.prank(admin);
        token.setMintAllowance(system, 100e18);
    }

    function test_gas_recording() public {
        vm.startPrank(system);
        uint256 gas = gasleft();
        token.mint(user1, 1e18);
        uint256 gasUsed = gas - gasleft();
        vm.stopPrank();
        console.log("gasUsed for mint", gasUsed);

        vm.startPrank(user1);
        gas = gasleft();
        token.transfer(user2, 1e18);
        gasUsed = gas - gasleft();
        vm.stopPrank();
        console.log("gasUsed for transfer", gasUsed);

        vm.startPrank(user2);
        gas = gasleft();
        token.approve(user1, 1e18);
        gasUsed = gas - gasleft();
        vm.stopPrank();
        console.log("gasUsed for approve", gasUsed);

        vm.startPrank(user1);
        gas = gasleft();
        token.transferFrom(user2, user1, 1e18);
        gasUsed = gas - gasleft();
        vm.stopPrank();
        console.log("gasUsed for transferFrom", gasUsed);

        address user = vm.addr(0xabc123);
        bytes32 hash = keccak256("I hereby declare that I am the address owner.");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(0xabc123, hash);
        bytes memory signature = abi.encodePacked(r, s, v);


        vm.startPrank(system);
        token.mint(user, 1e18);
        gas = gasleft();
        token.burn(user, 1e18, hash, signature);
        gasUsed = gas - gasleft();
        vm.stopPrank();
        console.log("gasUsed for burn", gasUsed);
    }

}

