// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ControllerToken.sol";
import "../src/Validator.sol";
import {TokenFrontend} from "../src/tests/tokenfrontend.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "forge-std/console.sol";
import "../src/SwapV1V2.sol";

import "../src/controllers/EthereumControllerToken.sol";
import "../src/controllers/PolygonControllerToken.sol";
import "../src/controllers/GnosisControllerToken.sol";

contract SwapV1V2Test is Test {
    ControllerToken public token;
    ERC1967Proxy public proxy;
    TokenFrontend public frontend;
    SwapV1V2 public swap;
    uint256 internal userPrivateKey;

    address user1 = vm.addr(1);
    address user2 = vm.addr(2);
    address system = vm.addr(3);
    Validator validator;
    address owner = address(0x1);
    address admin = address(0x2);
    address user = address(0x3);
    address blocked = address(0x4);
    address blacklisted = address(0x5);

    function setUp() public {
        // Deploy the implementation contract
        vm.prank(owner);
        ControllerToken implementation = new ControllerToken();
        validator = new Validator();

        // Deploy the proxy contract
        bytes memory initData = abi.encodeWithSelector(
            ControllerToken.initialize.selector,
            "Monerium EUR emoney",
            "EURE",
            bytes3("EUR"),
            address(validator)
        );
        proxy = new ERC1967Proxy(address(implementation), initData);

        // Cast the proxy address to the Token interface
        token = ControllerToken(address(proxy));

        frontend = new TokenFrontend(
            "Monerium EUR emoney",
            "EURE",
            bytes3("EUR")
        );

        token.setFrontend(address(frontend));
        frontend.setController(address(token));

        // Init the Token contract for minting and transfer test.
        token.addSystemAccount(system);
        token.addAdminAccount(admin);
        token.setMaxMintAllowance(3e18);

        vm.prank(admin);
        token.setMintAllowance(system, 3e18);

        vm.startPrank(system);
        token.mint(user1, 1e18);
        token.mint(user2, 1e18);
        vm.stopPrank();

        // Deploy SwapV1V2 contract with token as V1 and frontend as V2
        swap = new SwapV1V2(address(token), address(frontend), owner);
    }

    function test_setup() public {
        assertEq(token.ticker(), bytes3("EUR"));
        assertEq(address(token.validator()), address(validator));
        assertEq(swap.V1(), address(token));
        assertEq(swap.V2(), address(frontend));
        assertEq(swap.owner(), owner);
    }

    function test_swapExactIn_V1ToV2() public {
        uint256 amount = 1e17; // 0.1 tokens

        // User1 approves swap contract
        vm.prank(user1);
        token.approve(address(swap), amount);

        // Check initial balances
        uint256 user1TokenBefore = token.balanceOf(user1);
        uint256 user1FrontendBefore = frontend.balanceOf(user1);
        assertEq(user1FrontendBefore, user1TokenBefore);

        // Perform swap
        vm.prank(user1);
        uint256 amountOut = swap.swapExactIn(
            address(token),
            address(frontend),
            amount,
            amount,
            user1
        );

        // Check results
        assertEq(amountOut, amount);
        assertEq(token.balanceOf(user1), user1TokenBefore);
        assertEq(frontend.balanceOf(user1), user1FrontendBefore);
    }

    function test_swapExactIn_V2ToV1() public {
        uint256 amount = 1e17; // 0.1 tokens

        // User1 approves swap contract
        vm.prank(user1);
        token.approve(address(swap), amount);

        // Check initial balances
        uint256 user1TokenBefore = token.balanceOf(user1);
        uint256 user1FrontendBefore = frontend.balanceOf(user1);
        assertEq(user1FrontendBefore, user1TokenBefore);

        // Perform swap
        vm.prank(user1);
        uint256 amountOut = swap.swapExactIn(
            address(frontend),
            address(token),
            amount,
            amount,
            user1
        );

        // Check results
        assertEq(amountOut, amount);
        assertEq(token.balanceOf(user1), user1TokenBefore);
        assertEq(frontend.balanceOf(user1), user1FrontendBefore);
    }

    function test_swapExactIn_RevertBadPair() public {
        vm.prank(user1);
        vm.expectRevert(SwapV1V2.BadPair.selector);
        swap.swapExactIn(address(token), address(token), 1e17, 1e17, user1);
    }

    function test_swapExactIn_RevertZeroAmount() public {
        vm.prank(user1);
        vm.expectRevert(SwapV1V2.ZeroAmount.selector);
        swap.swapExactIn(address(token), address(frontend), 0, 0, user1);
    }

    function test_swapExactIn_RevertSlippage() public {
        uint256 amount = 1e17;
        uint256 minOut = amount + 1; // More than we can get (slippage protection)

        vm.prank(user1);
        token.approve(address(swap), amount);

        vm.prank(user1);
        vm.expectRevert(bytes("slip"));
        swap.swapExactIn(
            address(token),
            address(frontend),
            amount,
            minOut,
            user1
        );
    }

    function test_quote_ValidPair() public {
        uint256 amount = 1e18;
        uint256 quote = swap.quote(address(token), address(frontend), amount);
        assertEq(quote, amount);

        quote = swap.quote(address(frontend), address(token), amount);
        assertEq(quote, amount);
    }

    function test_quote_InvalidPair() public {
        uint256 amount = 1e18;
        uint256 quote = swap.quote(address(token), address(token), amount);
        assertEq(quote, 0);
    }

    function test_swapWithPermitBestEffort_EmptyCalldata() public {
        uint256 amount = 1e17;

        vm.prank(user1);
        token.approve(address(swap), amount);

        vm.prank(user1);
        uint256 amountOut = swap.swapWithPermitBestEffort(
            address(frontend),
            address(token),
            amount,
            amount,
            user1,
            ""
        );

        assertEq(amountOut, amount);
    }

    function test_swapExactIn_EmitsSwappedEvent() public {
        uint256 amount = 1e17;

        vm.prank(user1);
        token.approve(address(swap), amount);

        vm.recordLogs();

        vm.prank(user1);
        swap.swapExactIn(
            address(token),
            address(frontend),
            amount,
            amount,
            user1
        );

        Vm.Log[] memory logs = vm.getRecordedLogs();

        if (logs.length == 0) {
            assertTrue(false, "No events were emitted");
            return;
        }

        // Expected event signature
        bytes32 expectedSig = keccak256(
            "Swapped(address,address,address,uint256,address)"
        );
        
        // Find the Swapped event
        bool foundSwappedEvent = false;
        for (uint i = 0; i < logs.length; i++) {
            if (
                logs[i].emitter == address(swap) &&
                logs[i].topics[0] == expectedSig
            ) {
                foundSwappedEvent = true;

                // Verify we have the right number of topics (1 signature + 3 indexed params = 4 total)
                require(logs[i].topics.length == 4, "Wrong number of topics");

                // Verify indexed parameters (topics)
                address loggedCaller = address(
                    uint160(uint256(logs[i].topics[1]))
                );
                address loggedTokenIn = address(
                    uint160(uint256(logs[i].topics[2]))
                );
                address loggedTokenOut = address(
                    uint160(uint256(logs[i].topics[3]))
                );

                assertEq(loggedCaller, user1, "Caller mismatch");
                assertEq(loggedTokenIn, address(token), "TokenIn mismatch");
                assertEq(
                    loggedTokenOut,
                    address(frontend),
                    "TokenOut mismatch"
                );

                // Decode and verify non-indexed parameters
                if (logs[i].data.length > 0) {
                    (uint256 loggedAmount, address loggedTo) = abi.decode(
                        logs[i].data,
                        (uint256, address)
                    );
                    assertEq(loggedAmount, amount, "Amount mismatch");
                    assertEq(loggedTo, user1, "To address mismatch");
                } 
                break;
            }
        }

        assertTrue(foundSwappedEvent, "Swapped event not found");
    }

    function test_permit_functionality() public {
        uint256 amount = 1e17;
        uint256 deadline = block.timestamp + 3600;
        
        // Check initial allowance is 0
        assertEq(token.allowance(user1, address(swap)), 0);
        
        // Create permit signature
        uint256 nonce = token.nonces(user1);
        bytes32 digest = token.getPermitDigest(user1, address(swap), amount, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, digest);
        
        // Call permit
        vm.prank(user1);
        token.permit(user1, address(swap), amount, deadline, v, r, s);
        
        // Check allowance is now set
        assertEq(token.allowance(user1, address(swap)), amount);
        
        // Check nonce was incremented
        assertEq(token.nonces(user1), nonce + 1);
    }

    function test_swapWithPermitStrict_V2ToV1() public {
        uint256 amount = 1e17;
        uint256 deadline = block.timestamp + 3600;
        
        // Create permit signature
        uint256 nonce = token.nonces(user1);
        bytes32 digest = token.getPermitDigest(user1, address(swap), amount, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, digest); // user1's private key is 1
        
        uint256 user1TokenBefore = token.balanceOf(user1);
        uint256 user1FrontendBefore = frontend.balanceOf(user1);
        
        vm.prank(user1);
        uint256 amountOut = swap.swapWithPermitStrict(
            address(token),
            address(frontend),
            amount,
            amount,
            user1,
            deadline,
            v,
            r,
            s
        );
        
        assertEq(amountOut, amount);
        assertEq(token.balanceOf(user1), user1TokenBefore);
        assertEq(frontend.balanceOf(user1), user1FrontendBefore);
    }
    
    function test_swapWithPermitStrict_V1ToV2() public {
        uint256 amount = 1e17;
        uint256 deadline = block.timestamp + 3600;
        
        // Create permit signature
        // V1 does not support EIP-2612, so we use the token contract's permit function
        // this would have to be communicated to the user in a real-world scenario
        uint256 nonce = token.nonces(user1);
        bytes32 digest = token.getPermitDigest(user1, address(swap), amount, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, digest); // user1's private key is 1
        
        uint256 user1TokenBefore = token.balanceOf(user1);
        uint256 user1FrontendBefore = frontend.balanceOf(user1);
        
        vm.prank(user1);
        uint256 amountOut = swap.swapWithPermitStrict(
            address(frontend),
            address(token),
            amount,
            amount,
            user1,
            deadline,
            v,
            r,
            s
        );
        
        assertEq(amountOut, amount);
        assertEq(token.balanceOf(user1), user1TokenBefore);
        assertEq(frontend.balanceOf(user1), user1FrontendBefore);
    }

    function test_swapWithPermitStrict_RevertBadPair() public {
        uint256 amount = 1e17;
        uint256 deadline = block.timestamp + 3600;
        
        vm.prank(user1);
        vm.expectRevert(SwapV1V2.BadPair.selector);
        swap.swapWithPermitStrict(
            address(token),
            address(token),
            amount,
            amount,
            user1,
            deadline,
            0, 0, 0
        );
    }

    function test_swapWithPermitStrict_RevertZeroAmount() public {
        uint256 deadline = block.timestamp + 3600;
        
        vm.prank(user1);
        vm.expectRevert(SwapV1V2.ZeroAmount.selector);
        swap.swapWithPermitStrict(
            address(token),
            address(frontend),
            0,
            0,
            user1,
            deadline,
            0, 0, 0
        );
    }

    function test_swapWithPermitStrict_RevertSlippage() public {
        uint256 amount = 1e17;
        uint256 minOut = amount + 1;
        uint256 deadline = block.timestamp + 3600;
        
        vm.prank(user1);
        vm.expectRevert(bytes("slip"));
        swap.swapWithPermitStrict(
            address(token),
            address(frontend),
            amount,
            minOut,
            user1,
            deadline,
            0, 0, 0
        );
    }

    function test_swapWithPermitBestEffort_WithValidPermitData() public {
        uint256 amount = 1e17;
        uint256 deadline = block.timestamp + 3600;
        
        // Create permit signature
        uint256 nonce = token.nonces(user1);
        bytes32 digest = token.getPermitDigest(address(user1), address(swap), amount, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, digest);
        
        bytes memory permitCalldata = abi.encodePacked(deadline, v, r, s);
        assertEq(permitCalldata.length, 97, "Permit calldata should be 97 bytes");
        
        uint256 user1TokenBefore = token.balanceOf(user1);
        uint256 user1FrontendBefore = frontend.balanceOf(user1);
        
        vm.prank(user1);
        uint256 amountOut = swap.swapWithPermitBestEffort(
            address(token),
            address(frontend),
            amount,
            amount,
            user1,
            permitCalldata
        );
        
        assertEq(amountOut, amount);
        assertEq(token.balanceOf(user1), user1TokenBefore);
        assertEq(frontend.balanceOf(user1), user1FrontendBefore);
    }

    function test_swapWithPermitBestEffort_WithInvalidPermitData() public {
        uint256 amount = 1e17;
        
        // First approve manually since permit will fail
        vm.prank(user1);
        token.approve(address(swap), amount);
        
        // Invalid permit data (wrong length - should be 97 bytes but we'll use 96)
        bytes memory invalidPermitCalldata = abi.encode(
            block.timestamp + 3600,
            uint8(27),
            bytes32("invalid"),
            bytes32("signature")
        );
        // Truncate to make it invalid length
        assembly {
            mstore(invalidPermitCalldata, 96)
        }
        
        uint256 user1TokenBefore = token.balanceOf(user1);
        uint256 user1FrontendBefore = frontend.balanceOf(user1);
        
        vm.prank(user1);
        uint256 amountOut = swap.swapWithPermitBestEffort(
            address(token),
            address(frontend),
            amount,
            amount,
            user1,
            invalidPermitCalldata
        );
        
        // Should still work because permit is best effort and we have approval
        assertEq(amountOut, amount);
        assertEq(token.balanceOf(user1), user1TokenBefore);
        assertEq(frontend.balanceOf(user1), user1FrontendBefore);
    }

    function test_swapWithPermitBestEffort_RevertBadPair() public {
        vm.prank(user1);
        vm.expectRevert(SwapV1V2.BadPair.selector);
        swap.swapWithPermitBestEffort(
            address(token),
            address(token),
            1e17,
            1e17,
            user1,
            ""
        );
    }

    function test_swapWithPermitBestEffort_RevertZeroAmount() public {
        vm.prank(user1);
        vm.expectRevert(SwapV1V2.ZeroAmount.selector);
        swap.swapWithPermitBestEffort(
            address(token),
            address(frontend),
            0,
            0,
            user1,
            ""
        );
    }

    function test_swapWithPermitBestEffort_RevertSlippage() public {
        uint256 amount = 1e17;
        uint256 minOut = amount + 1;
        
        vm.prank(user1);
        vm.expectRevert(bytes("slip"));
        swap.swapWithPermitBestEffort(
            address(token),
            address(frontend),
            amount,
            minOut,
            user1,
            ""
        );
    }

    function test_constructor_RevertInvalidAddresses() public {
        // Test zero address for V1
        vm.expectRevert("bad address");
        new SwapV1V2(address(0), address(frontend), owner);
        
        // Test zero address for V2
        vm.expectRevert("bad address");
        new SwapV1V2(address(token), address(0), owner);
        
        // Test same address for V1 and V2
        vm.expectRevert("bad address");
        new SwapV1V2(address(token), address(token), owner);
    }

    function test_swapExactIn_DifferentToAddress() public {
        uint256 amount = 1e17;
        address recipient = address(0x999);
        
        vm.prank(user1);
        token.approve(address(swap), amount);
        
        uint256 user1TokenBefore = token.balanceOf(user1);
        uint256 recipientFrontendBefore = frontend.balanceOf(recipient);
        
        vm.prank(user1);
        uint256 amountOut = swap.swapExactIn(
            address(token),
            address(frontend),
            amount,
            amount,
            recipient
        );
        
        assertEq(amountOut, amount);
        assertEq(token.balanceOf(user1), user1TokenBefore - amount);
        assertEq(frontend.balanceOf(recipient), recipientFrontendBefore + amount);
    }

    function test_swapWithPermitStrict_DifferentToAddress() public {
        uint256 amount = 1e17;
        address recipient = address(0x999);
        uint256 deadline = block.timestamp + 3600;
        
        uint256 nonce = token.nonces(user1);
        bytes32 digest = token.getPermitDigest(user1, address(swap), amount, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, digest);
        
        uint256 user1TokenBefore = token.balanceOf(user1);
        uint256 recipientFrontendBefore = frontend.balanceOf(recipient);
        
        vm.prank(user1);
        uint256 amountOut = swap.swapWithPermitStrict(
            address(token),
            address(frontend),
            amount,
            amount,
            recipient,
            deadline,
            v,
            r,
            s
        );
        
        assertEq(amountOut, amount);
        assertEq(token.balanceOf(user1), user1TokenBefore - amount);
        assertEq(frontend.balanceOf(recipient), recipientFrontendBefore + amount);
    }

    function test_swapWithPermitBestEffort_DifferentToAddress() public {
        uint256 amount = 1e17;
        address recipient = address(0x999);
        
        vm.prank(user1);
        token.approve(address(swap), amount);
        
        uint256 user1TokenBefore = token.balanceOf(user1);
        uint256 recipientFrontendBefore = frontend.balanceOf(recipient);
        
        vm.prank(user1);
        uint256 amountOut = swap.swapWithPermitBestEffort(
            address(token),
            address(frontend),
            amount,
            amount,
            recipient,
            ""
        );
        
        assertEq(amountOut, amount);
        assertEq(token.balanceOf(user1), user1TokenBefore - amount);
        assertEq(frontend.balanceOf(recipient), recipientFrontendBefore + amount);
    }
}
