// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ControllerToken.sol";
import "../src/BlacklistValidatorUpgradeable.sol";
import "../src/tests/tokenfrontend.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "forge-std/console.sol";

import "../src/controllers/EthereumControllerToken.sol";
import "../src/controllers/PolygonControllerToken.sol";
import "../src/controllers/GnosisControllerToken.sol";

//import "forge-std/Vm.sol";

contract ControllerTokenTest is Test {
    ControllerToken public token;
    ERC1967Proxy public proxy;
    TokenFrontend public frontend;
    BlacklistValidatorUpgradeable public validator;
    uint256 internal userPrivateKey;

    address owner = address(this);

    address user1 = vm.addr(1);
    address user2 = vm.addr(2);
    address system = vm.addr(3);
    address admin = vm.addr(4);

    function setUp() public {
        // Deploy the implementation contract
        ControllerToken implementation = new ControllerToken();
        BlacklistValidatorUpgradeable blacklistValidator = new BlacklistValidatorUpgradeable();

        // Deploy the proxy contract
        bytes memory initDataProxy = abi.encodeWithSelector(
            BlacklistValidatorUpgradeable.initialize.selector
        );
        ERC1967Proxy validatorProxy = new ERC1967Proxy(
            address(blacklistValidator),
            initDataProxy
        );
        bytes memory initData = abi.encodeWithSelector(
            ControllerToken.initialize.selector,
            "Monerium EUR emoney",
            "EURE",
            bytes3("EUR"),
            address(validatorProxy)
        );

        proxy = new ERC1967Proxy(address(implementation), initData);
        // Cast the proxy address to the Token interface
        token = ControllerToken(address(proxy));
        validator = BlacklistValidatorUpgradeable(address(validatorProxy));

        userPrivateKey = 0xabc123;

        assertEq(token.name(), "Monerium EUR emoney");
        assertEq(token.owner(), address(this));

        frontend = new TokenFrontend(
            "Monerium EUR emoney",
            "EURE",
            bytes3("EUR")
        );

        token.setFrontend(address(frontend));
        assertTrue(token.isFrontend(address(frontend)));
        assertEq(token.getFrontend(), address(frontend));
        frontend.setController(address(token));
        assertEq(frontend.getController(), address(token));

        // Init the validator with an admin
        validator.addAdminAccount(admin);

        // Init the Token contract for minting and transfer test.
        token.addSystemAccount(system);
        token.addAdminAccount(admin);
        assertTrue(token.isSystemAccount(system));
        assertTrue(token.isAdminAccount(admin));
        token.setMaxMintAllowance(3e18);
        vm.prank(admin);
        token.setMintAllowance(system, 3e18);
        vm.startPrank(system);
        token.mint(user1, 1e18);
        token.mint(user2, 1e18);
        vm.stopPrank();
    }

    function test_ticker() public {
        assertEq(token.ticker(), bytes3("EUR"));
    }

    function test_ethereum_eur_should_return_right_frontend() public {
        bytes memory initData = abi.encodeWithSelector(
            EthereumControllerToken.initialize.selector,
            "Monerium EUR emoney",
            "EURE",
            bytes3("EUR"),
            address(validator)
        );

        EthereumControllerToken implementation = new EthereumControllerToken();
        EthereumControllerToken p = EthereumControllerToken(
            address(new ERC1967Proxy(address(implementation), initData))
        );
        EthereumControllerToken ethereumToken = EthereumControllerToken(
            address(p)
        );
        assertEq(
            ethereumToken.getFrontend(),
            0x3231Cb76718CDeF2155FC47b5286d82e6eDA273f
        );
    }

    function test_ethereum_usd_should_return_right_frontend() public {
        bytes memory initData = abi.encodeWithSelector(
            EthereumControllerToken.initialize.selector,
            "Monerium USD emoney",
            "USDE",
            bytes3("USD"),
            address(validator)
        );

        EthereumControllerToken implementation = new EthereumControllerToken();
        EthereumControllerToken p = EthereumControllerToken(
            address(new ERC1967Proxy(address(implementation), initData))
        );
        EthereumControllerToken ethereumToken = EthereumControllerToken(
            address(p)
        );
        assertEq(
            ethereumToken.getFrontend(),
            0xBc5142e0CC5eB16b47c63B0f033d4c2480853a52
        );
    }

    function test_ethereum_gbp_should_return_right_frontend() public {
        bytes memory initData = abi.encodeWithSelector(
            EthereumControllerToken.initialize.selector,
            "Monerium GBP emoney",
            "GBPE",
            bytes3("GBP"),
            address(validator)
        );

        EthereumControllerToken implementation = new EthereumControllerToken();
        EthereumControllerToken p = EthereumControllerToken(
            address(new ERC1967Proxy(address(implementation), initData))
        );
        EthereumControllerToken ethereumToken = EthereumControllerToken(
            address(p)
        );
        assertEq(
            ethereumToken.getFrontend(),
            0x7ba92741Bf2A568abC6f1D3413c58c6e0244F8fD
        );
    }

    function test_ethereum_isk_should_return_right_frontend() public {
        bytes memory initData = abi.encodeWithSelector(
            EthereumControllerToken.initialize.selector,
            "Monerium ISK emoney",
            "ISKE",
            bytes3("ISK"),
            address(validator)
        );

        EthereumControllerToken implementation = new EthereumControllerToken();
        EthereumControllerToken p = EthereumControllerToken(
            address(new ERC1967Proxy(address(implementation), initData))
        );
        EthereumControllerToken ethereumToken = EthereumControllerToken(
            address(p)
        );
        assertEq(
            ethereumToken.getFrontend(),
            0xC642549743A93674cf38D6431f75d6443F88E3E2
        );
    }

    function test_shouldTransfer() public {
        vm.prank(user1);
        frontend.transfer(user2, 1e18);

        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(user2), 2e18);
        assertEq(frontend.balanceOf(user1), 0);
        assertEq(frontend.balanceOf(user2), 2e18);
    }

    function test_should_not_transfer_to_token_or_frontend() public {
        vm.prank(user1);
        vm.expectRevert("Transfer to the token contract is not allowed");
        frontend.transfer(address(token), 1e18);
        vm.expectRevert("Transfer to the token contract is not allowed");
        frontend.transfer(address(frontend), 1e18);
    }

    function test_should_not_transferFrom_to_token_or_frontend() public {
        vm.prank(user1);
        vm.expectRevert("Transfer to the token contract is not allowed");
        frontend.transferFrom(user1, address(token), 1e18);
        vm.expectRevert("Transfer to the token contract is not allowed");
        frontend.transferFrom(user1, address(frontend), 1e18);
    }

    function test_shouldNotTransferIfBlacklisted() public {
        // Add user2 to blacklist
        vm.prank(admin);
        validator.ban(user1);
        assertTrue(validator.isBan(user1));

        vm.prank(user1);
        vm.expectRevert("Transfer not validated");
        frontend.transfer(user2, 1);
    }

    function test_from_banned_user_should_not_transferFrom() public {
        // Add user1 to blacklist
        vm.prank(admin);
        validator.ban(user1);
        assertTrue(validator.isBan(user1));

        vm.prank(user1);
        frontend.approve(user2, 1e18);

        vm.prank(user2);
        vm.expectRevert("Transfer not validated");
        frontend.transferFrom(user1, user2, 1);
    }

    function testFail_shouldNotTransferIfNotFromFrontend() public {
        vm.prank(user1);
        token.transfer_withCaller(user1, user2, 1e18);
    }

    function test_shouldApprove() public {
        vm.prank(user1);
        frontend.approve(user2, 1e18);

        assertEq(token.allowance(user1, user2), 1e18);
        assertEq(frontend.allowance(user1, user2), 1e18);
    }

    function testFail_shouldNotApproveIfNotFromFrontend() public {
        vm.prank(user1);
        token.approve_withCaller(user1, user2, 1e18);
    }

    function test_shouldTransferFrom() public {
        vm.prank(user1);
        frontend.approve(user2, 1e18);
        vm.prank(user2);
        frontend.transferFrom(user1, user2, 1e18);

        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(user2), 2e18);
    }

    function testFail_shouldNotTransferFromIfNotFromFrontend() public {
        vm.prank(user1);
        frontend.approve(user2, 1e18);
        assertEq(token.allowance(user1, user2), 1e18);

        token.transferFrom_withCaller(user2, user1, user2, 1e18);
    }

    function test_shouldTotalSupply() public {
        assertEq(frontend.totalSupply(), 2e18);
        assertEq(token.totalSupply(), 2e18);
    }

    function test_balanceOf() public {
        assertEq(frontend.balanceOf(user1), 1e18);
        assertEq(token.balanceOf(user1), 1e18);
    }

    function test_shouldDecimal() public {
        assertEq(frontend.decimals(), 18);
        assertEq(token.decimals(), 18);
    }

    function test_shouldMint() public {
        vm.prank(system);
        frontend.mintTo(user1, 1e18);
        assertEq(token.balanceOf(user1), 2e18);
        assertEq(frontend.balanceOf(user1), 2e18);
    }

    function testFail_shouldNotMintIfNotFromFrontend() public {
        vm.prank(system);
        token.mintTo_withCaller(system, user1, 1e18);
    }

    function testFail_BurnShouldRevert() public {
        address user = vm.addr(userPrivateKey);
        bytes32 hash = keccak256("burn");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, hash);

        vm.prank(system);
        frontend.mintTo(user, 1e18);
        assertEq(token.balanceOf(user), 1e18);

        vm.prank(system);
        frontend.burnFrom(user, 1e18, hash, v, r, s);
    }

    function testFail_RecoverShouldRevert() public {
        address user = vm.addr(userPrivateKey);
        bytes32 hash = keccak256("burn");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, hash);

        vm.prank(system);
        frontend.mintTo(user, 1e18);
        assertEq(token.balanceOf(user), 1e18);

        vm.prank(system);
        frontend.recover(user, user1, hash, v, r, s);
    }

    function testFail_ShouldNotRecoverNotFromFrontend() public {
        address user = vm.addr(userPrivateKey);
        bytes32 hash = keccak256("burn");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, hash);

        vm.prank(system);
        frontend.mintTo(user, 1e18);
        assertEq(token.balanceOf(user), 1e18);

        vm.prank(system);
        token.recover_withCaller(system, user, user1, hash, v, r, s);
    }

    function testFail_ShouldNotBurnNotFromFrontend() public {
        address user = vm.addr(userPrivateKey);
        bytes32 hash = keccak256("burn");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, hash);

        vm.prank(system);
        frontend.mintTo(user, 1e18);
        assertEq(token.balanceOf(user), 1e18);

        vm.prank(system);
        token.burnFrom_withCaller(system, user, 1e18, hash, v, r, s);
    }
}
