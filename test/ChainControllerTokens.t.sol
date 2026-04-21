// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {Validator} from "../src/Validator.sol";
import "../src/ControllerToken.sol";
import "../src/controllers/EthereumControllerToken.sol";
import "../src/controllers/GnosisControllerToken.sol";
import "../src/controllers/PolygonControllerToken.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

// Shared test logic for chain-specific ControllerToken variants.
// These contracts hardcode the V1 frontend address per ticker, so tests
// use vm.prank(hardcodedFrontend) instead of a deployed TokenFrontend.
abstract contract ChainControllerTokenTest is Test {
    ControllerToken public token;
    Validator public validator;

    address owner = address(this);
    address user1 = vm.addr(1);
    address user2 = vm.addr(2);
    address system = vm.addr(3);
    address admin = vm.addr(4);

    // Set by each subclass to the hardcoded EUR frontend address
    address internal v1Frontend;

    function _deployImpl() internal virtual returns (address);

    function setUp() public {
        address impl = _deployImpl();
        validator = new Validator();

        bytes memory initData = abi.encodeWithSelector(
            ControllerToken.initialize.selector,
            "Monerium EUR emoney",
            "EURE",
            bytes3("EUR"),
            address(validator)
        );

        ERC1967Proxy proxy = new ERC1967Proxy(impl, initData);
        token = ControllerToken(address(proxy));

        validator.setAdmin(admin);
        token.addSystemAccount(system);
        token.addAdminAccount(admin);
        token.setMaxMintAllowance(3e18);
        vm.prank(admin);
        token.setMintAllowance(system, 3e18);
        vm.startPrank(system);
        token.mint(user1, 1e18);
        token.mint(user2, 1e18);
        vm.stopPrank();
    }

    function test_getFrontend_returnsHardcodedAddress() public {
        assertEq(token.getFrontend(), v1Frontend);
    }

    function test_isFrontend_true() public {
        assertTrue(token.isFrontend(v1Frontend));
    }

    function test_isFrontend_false() public {
        assertFalse(token.isFrontend(address(0xdead)));
    }

    function test_v1Block_blocksTransferFromV1() public {
        validator.setAdmin(admin);
        vm.prank(admin);
        validator.setV1Blocked(user1);

        vm.prank(v1Frontend);
        vm.expectRevert(abi.encodeWithSelector(ControllerToken.V1Blocked.selector, user1));
        token.transfer_withCaller(user1, user2, 0.1e18);
    }

    function test_v1Block_blocksTransferToV1() public {
        vm.prank(admin);
        validator.setV1Blocked(user2);

        vm.prank(v1Frontend);
        vm.expectRevert(abi.encodeWithSelector(ControllerToken.V1Blocked.selector, user2));
        token.transfer_withCaller(user1, user2, 0.1e18);
    }

    function test_v1Block_allowsV2DirectTransfer() public {
        vm.prank(admin);
        validator.setV1Blocked(user2);

        vm.prank(user1);
        token.transfer(user2, 0.1e18);
        assertEq(token.balanceOf(user2), 1.1e18);
    }

    function test_transfer_withCaller_succeeds() public {
        vm.prank(v1Frontend);
        token.transfer_withCaller(user1, user2, 0.1e18);
        assertEq(token.balanceOf(user2), 1.1e18);
    }

    function test_transfer_withCaller_onlyFrontend() public {
        vm.expectRevert("ControllerToken: caller is not the frontend");
        token.transfer_withCaller(user1, user2, 0.1e18);
    }
}

contract EthereumControllerTokenTest is ChainControllerTokenTest {
    function _deployImpl() internal override returns (address) {
        v1Frontend = 0x3231Cb76718CDeF2155FC47b5286d82e6eDA273f; // EUR on Ethereum
        return address(new EthereumControllerToken());
    }
}

contract GnosisControllerTokenTest is ChainControllerTokenTest {
    function _deployImpl() internal override returns (address) {
        v1Frontend = 0xcB444e90D8198415266c6a2724b7900fb12FC56E; // EUR on Gnosis
        return address(new GnosisControllerToken());
    }
}

contract PolygonControllerTokenTest is ChainControllerTokenTest {
    function _deployImpl() internal override returns (address) {
        v1Frontend = 0x18ec0A6E18E5bc3784fDd3a3634b31245ab704F6; // EUR on Polygon
        return address(new PolygonControllerToken());
    }
}
