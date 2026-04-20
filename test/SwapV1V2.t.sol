// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ControllerToken.sol";
import "../src/Validator.sol";
import {TokenFrontend} from "../src/tests/tokenfrontend.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
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
    ERC1967Proxy public swapProxy;
    uint256 internal userPrivateKey;

    event Swapped(
        address indexed caller,
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        address to
    );

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

        // Deploy SwapV1V2 implementation contract
        SwapV1V2 swapImplementation = new SwapV1V2();

        // Deploy SwapV1V2 proxy with initialization
        bytes memory swapInitData = abi.encodeWithSelector(
            SwapV1V2.initialize.selector,
            address(frontend), // V1
            address(token),    // V2
            owner
        );
        swapProxy = new ERC1967Proxy(address(swapImplementation), swapInitData);

        // Cast the proxy address to SwapV1V2 interface
        swap = SwapV1V2(address(swapProxy));
    }

    function test_setup() public {
        assertEq(token.ticker(), bytes3("EUR"));
        assertEq(address(token.validator()), address(validator));
        assertEq(swap.V1(), address(frontend));
        assertEq(swap.V2(), address(token));
        assertEq(swap.owner(), owner);
    }

    function test_swapExactIn_V1ToV2() public {
        uint256 amount = 1e17; // 0.1 tokens

        // User1 approves swap contract
        vm.prank(user1);
        frontend.approve(address(swap), amount);

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

    function test_swapExactIn_V1ToV2_DifferentToAddress() public {
        uint256 amount = 1e17; // 0.1 tokens

        // User1 approves swap contract
        vm.prank(user1);
        frontend.approve(address(swap), amount);

        // Check initial balances
        uint256 user1BalanceBefore = token.balanceOf(user1);
        uint256 user2BalanceBefore = token.balanceOf(user2);

        // Perform swap
        vm.prank(user1);
        uint256 amountOut = swap.swapExactIn(
            address(frontend),
            address(token),
            amount,
            amount,
            user2
        );

        // Check results
        assertEq(amountOut, amount);
        assertEq(token.balanceOf(user1), user1BalanceBefore - amount);
        assertEq(frontend.balanceOf(user1), user1BalanceBefore - amount);
        assertEq(token.balanceOf(user2), user2BalanceBefore + amount);
        assertEq(frontend.balanceOf(user2), user2BalanceBefore + amount);
    }

    function test_swapExactIn_V2ToV1_DifferentToAddress() public {
        uint256 amount = 1e17; // 0.1 tokens

        // User1 approves swap contract
        vm.prank(user1);
        token.approve(address(swap), amount);

        // Check initial balances
        uint256 user1BalanceBefore = token.balanceOf(user1);
        uint256 user2BalanceBefore = token.balanceOf(user2);

        // Perform swap
        vm.prank(user1);
        uint256 amountOut = swap.swapExactIn(
            address(token),
            address(frontend),
            amount,
            amount,
            user2
        );

        // Check results
        assertEq(amountOut, amount);
        assertEq(token.balanceOf(user1), user1BalanceBefore - amount);
        assertEq(frontend.balanceOf(user1), user1BalanceBefore - amount);
        assertEq(token.balanceOf(user2), user2BalanceBefore + amount);
        assertEq(frontend.balanceOf(user2), user2BalanceBefore + amount);
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
        vm.expectRevert(SwapV1V2.Slippage.selector);
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

        // Check initial balances
        uint256 user1TokenBefore = token.balanceOf(user1);
        uint256 user1FrontendBefore = frontend.balanceOf(user1);
        assertEq(user1FrontendBefore, user1TokenBefore);

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

        // Check results
        assertEq(amountOut, amount);
        assertEq(token.balanceOf(user1), user1TokenBefore);
        assertEq(frontend.balanceOf(user1), user1FrontendBefore);

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
        bytes32 digest = token.getPermitDigest(
            user1,
            address(swap),
            amount,
            nonce,
            deadline
        );
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
        bytes32 digest = token.getPermitDigest(
            user1,
            address(swap),
            amount,
            nonce,
            deadline
        );
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

    function test_swapWithPermitStrict_V2ToV1_DifferentToAddress() public {
        uint256 amount = 1e17;
        uint256 deadline = block.timestamp + 3600;

        // Create permit signature
        uint256 nonce = token.nonces(user1);
        bytes32 digest = token.getPermitDigest(
            user1,
            address(swap),
            amount,
            nonce,
            deadline
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, digest); // user1's private key is 1

        uint256 user1BalanceBefore = token.balanceOf(user1);
        uint256 user2BalanceBefore = token.balanceOf(user2);

        vm.prank(user1);
        uint256 amountOut = swap.swapWithPermitStrict(
            address(token),
            address(frontend),
            amount,
            amount,
            user2,
            deadline,
            v,
            r,
            s
        );

        assertEq(amountOut, amount);
        assertEq(token.balanceOf(user1), user1BalanceBefore - amount);
        assertEq(token.balanceOf(user2), user2BalanceBefore + amount);
    }

    function test_swapWithPermitStrict_V1ToV2() public {
        uint256 amount = 1e17;
        uint256 deadline = block.timestamp + 3600;

        // For V1->V2 swap, we need to approve the frontend tokens
        // Since frontend doesn't support permit, we need to approve manually
        vm.prank(user1);
        frontend.approve(address(swap), amount);

        // Create permit signature for token (but this won't be used since we're going V1->V2)
        // We'll use dummy permit data since the function still expects permit parameters
        uint256 nonce = token.nonces(user1);
        bytes32 digest = token.getPermitDigest(
            user1,
            address(swap),
            amount,
            nonce,
            deadline
        );
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
            0,
            0,
            0
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
            0,
            0,
            0
        );
    }

    function test_swapWithPermitStrict_RevertSlippage() public {
        uint256 amount = 1e17;
        uint256 minOut = amount + 1;
        uint256 deadline = block.timestamp + 3600;

        vm.prank(user1);
        vm.expectRevert(SwapV1V2.Slippage.selector);
        swap.swapWithPermitStrict(
            address(token),
            address(frontend),
            amount,
            minOut,
            user1,
            deadline,
            0,
            0,
            0
        );
    }

    function test_swapWithPermitBestEffort_WithValidPermitData() public {
        uint256 amount = 1e17;
        uint256 deadline = block.timestamp + 3600;

        // Create permit signature
        uint256 nonce = token.nonces(user1);
        bytes32 digest = token.getPermitDigest(
            address(user1),
            address(swap),
            amount,
            nonce,
            deadline
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, digest);

        bytes memory permitCalldata = abi.encodePacked(deadline, v, r, s);
        assertEq(
            permitCalldata.length,
            97,
            "Permit calldata should be 97 bytes"
        );

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
        vm.expectRevert(SwapV1V2.Slippage.selector);
        swap.swapWithPermitBestEffort(
            address(token),
            address(frontend),
            amount,
            minOut,
            user1,
            ""
        );
    }

    function test_initialize_RevertInvalidAddresses() public {
        SwapV1V2 swapImplementation = new SwapV1V2();
        
        // Test zero address for V1
        vm.expectRevert(SwapV1V2.BadAddress.selector);
        bytes memory initData1 = abi.encodeWithSelector(
            SwapV1V2.initialize.selector,
            address(0),
            address(frontend),
            owner
        );
        new ERC1967Proxy(address(swapImplementation), initData1);

        // Test zero address for V2
        vm.expectRevert(SwapV1V2.BadAddress.selector);
        bytes memory initData2 = abi.encodeWithSelector(
            SwapV1V2.initialize.selector,
            address(token),
            address(0),
            owner
        );
        new ERC1967Proxy(address(swapImplementation), initData2);

        // Test same address for V1 and V2
        vm.expectRevert(SwapV1V2.BadAddress.selector);
        bytes memory initData3 = abi.encodeWithSelector(
            SwapV1V2.initialize.selector,
            address(token),
            address(token),
            owner
        );
        new ERC1967Proxy(address(swapImplementation), initData3);
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
        assertEq(
            frontend.balanceOf(recipient),
            recipientFrontendBefore + amount
        );
    }

    function test_swapWithPermitStrict_DifferentToAddress() public {
        uint256 amount = 1e17;
        address recipient = address(0x999);
        uint256 deadline = block.timestamp + 3600;

        uint256 nonce = token.nonces(user1);
        bytes32 digest = token.getPermitDigest(
            user1,
            address(swap),
            amount,
            nonce,
            deadline
        );
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
        assertEq(
            frontend.balanceOf(recipient),
            recipientFrontendBefore + amount
        );
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
        assertEq(
            frontend.balanceOf(recipient),
            recipientFrontendBefore + amount
        );
    }

    function test_swapWithPermitBestEffort_WithFailingPermitCall() public {
        uint256 amount = 1e17;
        uint256 deadline = block.timestamp + 3600;

        // Create permit signature with wrong private key (will fail)
        uint256 nonce = token.nonces(user1);
        bytes32 digest = token.getPermitDigest(
            user1,
            address(swap),
            amount,
            nonce,
            deadline
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(2, digest); // Wrong key

        bytes memory permitCalldata = abi.encodePacked(deadline, v, r, s);
        assertEq(
            permitCalldata.length,
            97,
            "Permit calldata should be 97 bytes"
        );

        // Manually approve since permit will fail
        vm.prank(user1);
        token.approve(address(swap), amount);

        uint256 user1TokenBefore = token.balanceOf(user1);
        uint256 user1FrontendBefore = frontend.balanceOf(user1);

        vm.prank(user1);
        uint256 amountOut = swap.swapWithPermitBestEffort(
            address(token),
            address(frontend),
            amount,
            amount,
            user2, // Different address
            permitCalldata
        );

        // Should work because it's best effort and we have manual approval
        assertEq(amountOut, amount);
        assertEq(token.balanceOf(user1), user1TokenBefore - amount);
        assertEq(frontend.balanceOf(user2), user1FrontendBefore + amount);
    }

    function test_swapWithPermitBestEffort_SameToAddress_WithInvalidPermitData()
        public
    {
        uint256 amount = 1e17;

        // Now requires approval even with invalid permit data since we always execute transfers
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
            user1, // Same address as sender
            invalidPermitCalldata
        );

        // Now transfers are always executed, but with shared storage the net effect is zero
        assertEq(amountOut, amount);
        assertEq(token.balanceOf(user1), user1TokenBefore);
        assertEq(frontend.balanceOf(user1), user1FrontendBefore);
    }

    function test_upgrade_functionality() public {
        // Deploy new implementation
        SwapV1V2 newImplementation = new SwapV1V2();
        
        // Verify current state before upgrade
        assertEq(swap.V1(), address(frontend));
        assertEq(swap.V2(), address(token));
        assertEq(swap.owner(), owner);
        
        // Perform upgrade as owner
        vm.prank(owner);
        UUPSUpgradeable(address(swap)).upgradeToAndCall(
            address(newImplementation),
            ""
        );
        
        // Verify state is preserved after upgrade
        assertEq(swap.V1(), address(frontend));
        assertEq(swap.V2(), address(token));
        assertEq(swap.owner(), owner);
        
        // Verify functionality still works after upgrade
        uint256 amount = 1e17;
        vm.prank(user1);
        token.approve(address(swap), amount);
        
        vm.prank(user1);
        uint256 amountOut = swap.swapExactIn(
            address(token),
            address(frontend),
            amount,
            amount,
            user1
        );
        assertEq(amountOut, amount);
    }

    function test_upgrade_onlyOwner() public {
        SwapV1V2 newImplementation = new SwapV1V2();
        
        // Try to upgrade as non-owner, should fail
        vm.prank(user1);
        vm.expectRevert();
        UUPSUpgradeable(address(swap)).upgradeToAndCall(
            address(newImplementation),
            ""
        );
    }

    function test_sellGem_V1_to_V2() public {
        uint256 amount = 1e17;
        
        // User1 approves and sells V1 (frontend) for V2 (token)
        vm.prank(user1);
        frontend.approve(address(swap), amount);
        
        uint256 user1V1Before = frontend.balanceOf(user1);
        uint256 user2V2Before = token.balanceOf(user2);
        
        vm.prank(user1);
        uint256 outWad = swap.sellGem(user2, amount);
        
        // Both tokens use 18 decimals, so conversion factor is 1
        assertEq(outWad, amount);
        assertEq(frontend.balanceOf(user1), user1V1Before - amount);
        assertEq(token.balanceOf(user2), user2V2Before + amount);
    }

    function test_buyGem_V2_to_V1() public {
        uint256 amount = 1e17;
        
        // User1 approves and buys V1 (frontend) with V2 (token)  
        vm.prank(user1);
        token.approve(address(swap), amount);
        
        uint256 user1V2Before = token.balanceOf(user1);
        uint256 user2V1Before = frontend.balanceOf(user2);
        
        vm.prank(user1);
        uint256 inWad = swap.buyGem(user2, amount);
        
        // Both tokens use 18 decimals, so conversion factor is 1
        assertEq(inWad, amount);
        assertEq(token.balanceOf(user1), user1V2Before - amount);
        assertEq(frontend.balanceOf(user2), user2V1Before + amount);
    }

    function test_sellGem_revert_ZeroAmount() public {
        vm.prank(user1);
        vm.expectRevert(SwapV1V2.ZeroAmount.selector);
        swap.sellGem(user2, 0);
    }

    function test_buyGem_revert_ZeroAmount() public {
        vm.prank(user1);
        vm.expectRevert(SwapV1V2.ZeroAmount.selector);
        swap.buyGem(user2, 0);
    }

    function test_sellGem_event_emission() public {
        uint256 amount = 1e17;
        
        vm.prank(user1);
        frontend.approve(address(swap), amount);
        
        vm.prank(user1);
        vm.expectEmit(true, true, true, true, address(swap));
        emit Swapped(user1, address(frontend), address(token), amount, user2);
        swap.sellGem(user2, amount);
    }

    function test_buyGem_event_emission() public {
        uint256 amount = 1e17;
        
        vm.prank(user1);
        token.approve(address(swap), amount);
        
        vm.prank(user1);
        vm.expectEmit(true, true, true, true, address(swap));
        emit Swapped(user1, address(token), address(frontend), amount, user2);
        swap.buyGem(user2, amount);
    }

    function test_sellGem_sameAddress_requiresApproval() public {
        uint256 amount = 1e17;
        
        // Should revert without approval, even when msg.sender == usr
        vm.prank(user1);
        vm.expectRevert();
        swap.sellGem(user1, amount);
        
        // Works correctly with approval
        vm.prank(user1);
        frontend.approve(address(swap), amount);
        
        uint256 user1V1Before = frontend.balanceOf(user1);
        uint256 user1V2Before = token.balanceOf(user1);
        
        vm.prank(user1);
        uint256 outWad = swap.sellGem(user1, amount);
        
        uint256 user1V1After = frontend.balanceOf(user1);
        uint256 user1V2After = token.balanceOf(user1);
        
        // Transfers are executed, but with shared storage net effect is zero
        assertEq(outWad, amount, "Function returns correct amount");
        assertEq(user1V1After, user1V1Before, "Shared storage: V1 balance unchanged");
        assertEq(user1V2After, user1V2Before, "Shared storage: V2 balance unchanged");
    }

    function test_buyGem_sameAddress_requiresApproval() public {
        uint256 amount = 1e17;
        
        // Should revert without approval, even when msg.sender == usr
        vm.prank(user1);
        vm.expectRevert();
        swap.buyGem(user1, amount);
        
        // Works correctly with approval
        vm.prank(user1);
        token.approve(address(swap), amount);
        
        uint256 user1V1Before = frontend.balanceOf(user1);
        uint256 user1V2Before = token.balanceOf(user1);
        
        vm.prank(user1);
        uint256 inWad = swap.buyGem(user1, amount);
        
        uint256 user1V1After = frontend.balanceOf(user1);
        uint256 user1V2After = token.balanceOf(user1);
        
        // Transfers are executed, but with shared storage net effect is zero
        assertEq(inWad, amount, "Function returns correct amount");
        assertEq(user1V1After, user1V1Before, "Shared storage: V1 balance unchanged");
        assertEq(user1V2After, user1V2Before, "Shared storage: V2 balance unchanged");
    }


    // PoC for L2: Unwrapped permit enables front-run griefing
    // Alice consumes Bob's permit nonce before his tx is mined.
    // Bob's swapWithPermitStrict then reverts at the permit() call even
    // though the allowance is already set — the swap is blocked.
    function test_L2_permitFrontRunGriefing_POC() public {
        uint256 amount = 1e17;
        uint256 deadline = type(uint256).max;

        // Bob creates a valid ERC-2612 permit signature (private key = 1)
        uint256 nonce = token.nonces(user1);
        bytes32 digest = token.getPermitDigest(user1, address(swap), amount, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, digest);

        // Alice front-runs: submits Bob's permit signature before his tx lands
        vm.prank(user2);
        token.permit(user1, address(swap), amount, deadline, v, r, s);

        // Alice's tx consumed the nonce — allowance IS set for Bob
        assertEq(token.allowance(user1, address(swap)), amount, "allowance set by front-runner");

        // Bob's tx now hits swapWithPermitStrict with a spent nonce → reverts
        // Despite the allowance being present, the swap is griefed
        // Bob's swap should succeed — the allowance is already set by Alice's front-run.
        // BUG: swapWithPermitStrict calls permit() unconditionally, so it reverts with
        // ERC2612InvalidSigner because the nonce was already consumed. This test fails
        // until permit() is wrapped in try/catch.
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
    }

    function test_reentrancy_attack() public {
        // Create a malicious token that attempts reentrancy
        ReentrantToken maliciousToken = new ReentrantToken(address(swap));

        // Deploy new swap contract with malicious token
        SwapV1V2 maliciousSwapImplementation = new SwapV1V2();
        bytes memory maliciousInitData = abi.encodeWithSelector(
            SwapV1V2.initialize.selector,
            address(maliciousToken),
            address(frontend),
            owner
        );
        ERC1967Proxy maliciousSwapProxy = new ERC1967Proxy(address(maliciousSwapImplementation), maliciousInitData);
        SwapV1V2 maliciousSwap = SwapV1V2(address(maliciousSwapProxy));

        // This should revert due to ReentrancyGuard
        vm.expectRevert();
        maliciousToken.triggerReentrancy(
            maliciousSwap,
            address(frontend),
            1e17,
            user1
        );
    }
}

// Helper contract for reentrancy test
contract ReentrantToken {
    address public swapContract;
    bool public attacking = false;

    constructor(address _swap) {
        swapContract = _swap;
    }

    function triggerReentrancy(
        SwapV1V2 swap,
        address tokenOut,
        uint256 amount,
        address to
    ) external {
        attacking = true;
        swap.swapExactIn(address(this), tokenOut, amount, amount, to);
    }

    function safeTransferFrom(
        address from,
        address /* to */,
        uint256 amount
    ) external {
        if (attacking) {
            attacking = false;
            // Attempt reentrancy
            SwapV1V2(swapContract).swapExactIn(
                address(this),
                msg.sender,
                amount,
                amount,
                from
            );
        }
    }

    function safeTransfer(address to, uint256 amount) external {
        // Do nothing
    }

    function balanceOf(address) external pure returns (uint256) {
        return 1e18;
    }

    function approve(address, uint256) external pure returns (bool) {
        return true;
    }

    function allowance(address, address) external pure returns (uint256) {
        return type(uint256).max;
    }
}
