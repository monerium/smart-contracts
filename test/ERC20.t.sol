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
        token.setLimitCap( 1e18);
        vm.startPrank(admin);
        token.setLimits(system, 1e18, 1e18);
        vm.stopPrank();
    }

    function test_invariant_metadata() public {
        assertEq(token.name(), "token");
        assertEq(token.symbol(), "EURE");
        assertEq(token.decimals(), 18);
    }

    function test_approve() public {
        vm.prank(user1);
        assertTrue(token.approve(user2, 1e18));

        assertEq(token.allowance(user1, user2), 1e18);
    }

    function test_transfer() public {
        vm.prank(system);
        token.mint(user1, 1e18);

        vm.prank(user1);
        assertTrue(token.transfer(user2, 1e18));
        assertEq(token.totalSupply(), 1e18);

        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(user2), 1e18);
    }

    function test_transferFrom() public {
        vm.prank(system);
        token.mint(user1, 1e18);

        vm.prank(user1);
        token.approve(user2, 1e18);

        vm.prank(user2);
        assertTrue(token.transferFrom(user1, user2, 1e18));
        assertEq(token.totalSupply(), 1e18);

        assertEq(token.allowance(user1, user2), 0);
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(user2), 1e18);
    }

    function test_infinite_approve_transferFrom() public {
        vm.prank(system);
        token.mint(user1, 1e18);

        vm.prank(user1);
        token.approve(user2, type(uint256).max);

        vm.prank(user2);
        assertTrue(token.transferFrom(user1, user2, 1e18));
        assertEq(token.totalSupply(), 1e18);

        assertEq(token.allowance(user1, user2), type(uint256).max);
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(user2), 1e18);
    }

    function testFail_transfer_insufficient_balance() public {
        vm.prank(system);
        token.mint(user1, 0.9e18);

        vm.prank(user1);
        token.transfer(user2, 1e18);
    }

    function testFail_transferFrom_insufficient_allowance() public {
        vm.prank(system);
        token.mint(user1, 1e18);

        vm.prank(user1);
        token.approve(user2, 0.9e18);

        vm.prank(user2);
        token.transferFrom(user1, user2, 1e18);
    }

    function testFail_transferFrom_insufficient_balance() public {
        vm.prank(system);
        token.mint(user1, 0.9e18);

        vm.prank(user1);
        token.approve(user2, 1e18);

        vm.prank(user2);
        token.transferFrom(user1, user2, 1e18);
    }

    function test_permit() public {
        uint256 privateKey = 0xabc123;
        address signer = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    token.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            signer,
                            user1,
                            1e18,
                            token.nonces(signer),
                            block.timestamp
                        )
                    )
                )
            )
        );

        token.permit(signer, user1, 1e18, block.timestamp, v, r, s);

        assertEq(token.allowance(signer, user1), 1e18);
        assertEq(token.nonces(signer), 1);
    }

    function test_permit_with_external_get_permit_digest() public {
        uint256 privateKey = 0xabc123;
        address signer = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            token.getPermitDigest(
                signer,
                user1,
                1e18,
                token.nonces(signer),
                block.timestamp
            )
        );

        token.permit(signer, user1, 1e18, block.timestamp, v, r, s);

        assertEq(token.allowance(signer, user1), 1e18);
        assertEq(token.nonces(signer), 1);
    }

    function testFail_permit_bad_nonce() public {
        uint256 privateKey = 0xabc123;
        address signer = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    token.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            signer,
                            user2,
                            1e18,
                            token.nonces(signer) + 1, // Bad nonce value
                            block.timestamp
                        )
                    )
                )
            )
        );

        token.permit(signer, user2, 1e18, block.timestamp, v, r, s);
    }

    function testFail_permit_bad_deadline() public {
        uint256 privateKey = 0xabc123;
        address signer = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    token.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            signer,
                            user2,
                            1e18,
                            token.nonces(signer),
                            block.timestamp
                        )
                    )
                )
            )
        );

        token.permit(signer, user2, 1e18, block.timestamp + 1, v, r, s); // Bad deadline
    }

    function testFail_permit_past_deadline() public {
        uint256 oldTimestamp = block.timestamp;
        uint256 privateKey = 0xabc123;
        address signer = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    token.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            signer,
                            user2,
                            1e18,
                            token.nonces(signer),
                            oldTimestamp
                        )
                    )
                )
            )
        );

        vm.warp(block.timestamp + 1);
        token.permit(signer, user2, 1e18, oldTimestamp, v, r, s); // Past deadline
    }

    function test_recover() public {
        uint256 amount = 1e18;
        uint256 privateKey = 0xabc123; // Assuming this private key corresponds to `user1`.
        address signer = vm.addr(privateKey);

        bytes32 messageHash = 0xb77c35c892a1b24b10a2ce49b424e578472333ee8d2456234fff90626332c50f;

        // Simulate signing the message by `user1`
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, messageHash);

        // Mint tokens to `user1`
        vm.prank(system);
        token.mint(signer, amount);

        // Check initial balances
        assertEq(token.balanceOf(signer), amount);
        assertEq(token.balanceOf(user2), 0);

        // Perform the recovery
        vm.prank(system);
        token.recover(signer, user2, messageHash, v, r, s);

        // Check final balances
        assertEq(token.balanceOf(signer), 0);
        assertEq(token.balanceOf(user2), amount);

        // Emit event check is optional, depends on testing framework capabilities

    }

    function test_recover_invalid_signature() public {
        uint256 amount = 1e18;
        uint256 privateKey = 0xabc123;
        address signer = vm.addr(privateKey);

        bytes32 messageHash = keccak256("Invalid hash");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, messageHash);

        // Mint tokens to `signer`
        vm.prank(system);
        token.mint(signer, amount);

        // Use an invalid signature
        vm.prank(system);
        vm.expectRevert("signature/hash does not match");
        token.recover(signer, user2, messageHash, v, r, s);
    }

    function test_recover_zero_addresses() public {
        uint256 amount = 1e18;
        uint256 privateKey = 0xabc123;
        address signer = vm.addr(privateKey);

        bytes32 messageHash = 0xb77c35c892a1b24b10a2ce49b424e578472333ee8d2456234fff90626332c50f;
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, messageHash);

        vm.prank(system);
        token.mint(signer, amount);

        // Attempt to recover to a zero address
        vm.prank(system);
        vm.expectRevert(
            abi.encodeWithSignature("ERC20InvalidReceiver(address)", address(0))
        );
        token.recover(signer, address(0), messageHash, v, r, s);
    }
}
