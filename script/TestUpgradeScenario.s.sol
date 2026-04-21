// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Validator} from "../src/Validator.sol";
import "../src/ControllerToken.sol";
import "../src/tests/tokenfrontend.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Token} from "../src/Token.sol";

/**
 * End-to-end upgrade scenario test.
 *
 * Simulates the production upgrade on a fresh network (local anvil or Sepolia).
 * Does NOT touch any existing deployed contracts.
 *
 * What it tests:
 *   1. Deploy setup: Validator + ControllerToken proxy + V1 TokenFrontend
 *   2. Mint tokens, run V1 and V2 transfers, record balances
 *   3. Blacklist charlie, verify transfers blocked on both V1 and V2
 *   4. Deploy new Validator, migrate charlie's blacklist entry
 *   5. Deploy new ControllerToken implementation, upgradeToAndCall + setValidator
 *   6. Verify balances unchanged after upgrade
 *   7. Verify charlie is still blocked on both V1 and V2
 *   8. Set dave as V1-blocked: V1 transfer reverts, V2 succeeds
 *
 * Required env vars:
 *   PRIVATE_KEY   — deployer/owner/system/admin (must have ETH on target network)
 *
 * Optional env vars (default to anvil well-known keys for local testing):
 *   ALICE_KEY     — sends V2 transfer pre-upgrade
 *   BOB_KEY       — sends V1 transfer pre-upgrade
 *   CHARLIE_KEY   — will be blacklisted
 *   DAVE_KEY      — will be V1-blocked
 *
 * Local usage (anvil defaults work out of the box):
 *   anvil
 *   forge script script/TestUpgradeScenario.s.sol:TestUpgradeScenario \
 *     --rpc-url http://localhost:8545 --broadcast -vvvv
 *
 * Sepolia usage (fund alice/bob/charlie/dave from Sepolia faucet first):
 *   forge script script/TestUpgradeScenario.s.sol:TestUpgradeScenario \
 *     --rpc-url $SEPOLIA_RPC --broadcast --verify \
 *     --etherscan-api-key $ETHERSCAN_API_KEY -vvvv
 */
contract TestUpgradeScenario is Script {
    // Anvil well-known private keys (accounts 1–4)
    uint256 constant ANVIL_KEY_1 = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
    uint256 constant ANVIL_KEY_2 = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;
    uint256 constant ANVIL_KEY_3 = 0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6;
    uint256 constant ANVIL_KEY_4 = 0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926b;

    // Shared state between phases
    uint256 deployerKey;
    uint256 aliceKey;
    uint256 bobKey;
    uint256 charlieKey;
    uint256 daveKey;

    address deployer;
    address alice;
    address bob;
    address charlie;
    address dave;

    ControllerToken token;
    TokenFrontend   frontend;
    Validator       oldValidator;

    // Balances captured before upgrade, compared after
    uint256 aliceBalance;
    uint256 bobBalance;
    uint256 daveBalance;

    function run() external {
        deployerKey = vm.envUint("PRIVATE_KEY");
        aliceKey    = vm.envOr("ALICE_KEY",   ANVIL_KEY_1);
        bobKey      = vm.envOr("BOB_KEY",     ANVIL_KEY_2);
        charlieKey  = vm.envOr("CHARLIE_KEY", ANVIL_KEY_3);
        daveKey     = vm.envOr("DAVE_KEY",    ANVIL_KEY_4);

        deployer = vm.addr(deployerKey);
        alice    = vm.addr(aliceKey);
        bob      = vm.addr(bobKey);
        charlie  = vm.addr(charlieKey);
        dave     = vm.addr(daveKey);

        _phase1_setup();
        _phase2_preUpgradeTransfers();
        _phase3_blacklistCharlie();

        Validator newValidator = _phase4_upgrade();

        _phase5_postUpgradeVerification(newValidator);
        _phase6_v1BlockTest(newValidator);

        console.log("");
        console.log("=== ALL TESTS PASSED ===");
        console.log("");
        console.log("Deployed addresses:");
        console.log("  Token proxy   :", address(token));
        console.log("  V1 Frontend   :", address(frontend));
        console.log("  New Validator :", address(newValidator));
    }

    function _phase1_setup() internal {
        console.log("=== Phase 1: Deploy setup ===");

        vm.startBroadcast(deployerKey);

        oldValidator = new Validator();
        oldValidator.setAdmin(deployer);

        ControllerToken impl1 = new ControllerToken();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl1),
            abi.encodeWithSelector(
                ControllerToken.initialize.selector,
                "Monerium EUR emoney",
                "EURe",
                bytes3("EUR"),
                address(oldValidator)
            )
        );
        token = ControllerToken(address(proxy));

        frontend = new TokenFrontend("Monerium EUR emoney", "EURe", bytes3("EUR"));
        token.setFrontend(address(frontend));
        frontend.setController(address(token));

        token.addSystemAccount(deployer);
        token.addAdminAccount(deployer);
        token.setMaxMintAllowance(type(uint256).max);
        token.setMintAllowance(deployer, type(uint256).max);

        token.mint(alice,   100 ether);
        token.mint(bob,      50 ether);
        token.mint(charlie,  30 ether);
        token.mint(dave,    200 ether);

        vm.stopBroadcast();

        console.log("Token proxy   :", address(token));
        console.log("V1 Frontend   :", address(frontend));
        console.log("Old Validator :", address(oldValidator));
        console.log("alice :", alice);
        console.log("bob   :", bob);
        console.log("charlie:", charlie);
        console.log("dave  :", dave);
    }

    function _phase2_preUpgradeTransfers() internal {
        console.log("");
        console.log("=== Phase 2: Pre-upgrade transfers ===");

        // V2 direct transfer: alice sends 10 to bob
        vm.startBroadcast(aliceKey);
        token.transfer(bob, 10 ether);
        vm.stopBroadcast();

        // V1 transfer: bob sends 5 to alice via frontend
        vm.startBroadcast(bobKey);
        frontend.transfer(alice, 5 ether);
        vm.stopBroadcast();

        // 100 - 10 + 5 = 95
        aliceBalance = token.balanceOf(alice);
        // 50 + 10 - 5 = 55
        bobBalance   = token.balanceOf(bob);
        daveBalance  = token.balanceOf(dave);

        require(aliceBalance == 95 ether, "alice pre-upgrade balance wrong");
        require(bobBalance   == 55 ether, "bob pre-upgrade balance wrong");
        console.log("PASS: V2 transfer alice->bob");
        console.log("PASS: V1 transfer bob->alice");
        console.log("alice:", aliceBalance, " bob:", bobBalance);
    }

    function _phase3_blacklistCharlie() internal {
        console.log("");
        console.log("=== Phase 3: Blacklist charlie ===");

        vm.startBroadcast(deployerKey);
        oldValidator.setBlacklisted(charlie);
        vm.stopBroadcast();

        require(oldValidator.isBlacklisted(charlie), "charlie not blacklisted");
        console.log("charlie blacklisted");

        vm.prank(charlie);
        try token.transfer(alice, 1 ether) {
            revert("charlie V2 send should revert");
        } catch { console.log("PASS: charlie V2 send blocked"); }

        vm.prank(alice);
        try token.transfer(charlie, 1 ether) {
            revert("V2 send to charlie should revert");
        } catch { console.log("PASS: V2 receive by charlie blocked"); }

        vm.prank(charlie);
        try frontend.transfer(alice, 1 ether) {
            revert("charlie V1 send should revert");
        } catch { console.log("PASS: charlie V1 send blocked"); }
    }

    function _phase4_upgrade() internal returns (Validator newValidator) {
        console.log("");
        console.log("=== Phase 4: Upgrade ===");

        vm.startBroadcast(deployerKey);

        newValidator = new Validator();
        newValidator.setAdmin(deployer);

        // Migrate blacklist
        newValidator.setBlacklisted(charlie);

        ControllerToken newImpl = new ControllerToken();

        UUPSUpgradeable(address(token)).upgradeToAndCall(address(newImpl), "");
        token.setValidator(address(newValidator));

        vm.stopBroadcast();

        console.log("New Validator :", address(newValidator));
        console.log("New impl      :", address(newImpl));
    }

    function _phase5_postUpgradeVerification(Validator newValidator) internal {
        console.log("");
        console.log("=== Phase 5: Post-upgrade verification ===");

        require(address(token.validator()) == address(newValidator), "validator not updated");
        console.log("PASS: validator updated");

        require(token.balanceOf(alice) == aliceBalance, "alice balance changed");
        require(token.balanceOf(bob)   == bobBalance,   "bob balance changed");
        require(token.balanceOf(dave)  == daveBalance,  "dave balance changed");
        console.log("PASS: all balances unchanged after upgrade");

        require(newValidator.isBlacklisted(charlie), "charlie not in new validator");
        console.log("PASS: charlie migrated to new validator");

        // Charlie still blocked on V2
        vm.prank(charlie);
        try token.transfer(alice, 1 ether) {
            revert("charlie post-upgrade V2 transfer should revert");
        } catch { console.log("PASS: charlie still blocked post-upgrade (V2)"); }

        // Charlie still blocked on V1
        vm.prank(charlie);
        try frontend.transfer(alice, 1 ether) {
            revert("charlie post-upgrade V1 transfer should revert");
        } catch { console.log("PASS: charlie still blocked post-upgrade (V1)"); }

        // Normal V2 transfer works
        vm.startBroadcast(aliceKey);
        token.transfer(bob, 1 ether);
        vm.stopBroadcast();
        console.log("PASS: normal V2 transfer works post-upgrade");

        // Normal V1 transfer works
        vm.startBroadcast(bobKey);
        frontend.transfer(alice, 1 ether);
        vm.stopBroadcast();
        console.log("PASS: normal V1 transfer works post-upgrade");
    }

    function _phase6_v1BlockTest(Validator newValidator) internal {
        console.log("");
        console.log("=== Phase 6: V1Block test ===");

        vm.startBroadcast(deployerKey);
        newValidator.setV1Blocked(dave);
        vm.stopBroadcast();

        require(newValidator.isV1Blocked(dave), "dave not V1-blocked");

        // V1 transfer from dave must fail
        vm.prank(dave);
        try frontend.transfer(alice, 1 ether) {
            revert("dave V1 transfer should revert");
        } catch { console.log("PASS: dave V1 transfer blocked (V1Blocked)"); }

        // V2 direct transfer from dave must succeed
        uint256 daveBefore = token.balanceOf(dave);
        vm.startBroadcast(daveKey);
        token.transfer(alice, 1 ether);
        vm.stopBroadcast();

        require(token.balanceOf(dave) == daveBefore - 1 ether, "dave V2 transfer failed");
        console.log("PASS: dave V2 direct transfer succeeds (V1Block does not apply to V2)");
    }
}
