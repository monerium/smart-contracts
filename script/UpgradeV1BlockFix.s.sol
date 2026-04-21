// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Validator.sol";
import "../src/Token.sol";
import "../src/controllers/EthereumControllerToken.sol";
import "../src/controllers/GnosisControllerToken.sol";
import "../src/controllers/PolygonControllerToken.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/**
 * Step 1 (permissionless — any EOA):
 *   Deploy the new Validator and ControllerToken implementation.
 *   No proxy ownership required.
 *
 * Step 2 (owner-only — executed by the Safe):
 *   The Safe calls on each proxy:
 *     proxy.upgradeToAndCall(newImpl, "")
 *     proxy.setValidator(newValidator)
 *   Use PrintSafeCalldata below to generate the calldata for the Safe Transaction Builder.
 *
 * Required env vars for Deploy* contracts:
 *   PRIVATE_KEY      - any funded EOA
 *   VALIDATOR_ADMIN  - address to grant ADMIN_ROLE on the new Validator
 *
 * Required env vars for PrintSafeCalldata:
 *   PROXY      - token proxy address
 *   IMPL       - new implementation address (from DeployImpl)
 *   VALIDATOR  - new Validator address (from DeployValidator.s.sol)
 */

// ── Step 1a: deploy new Validator ─────────────────────────────────────────────

contract DeployValidator is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address validatorAdmin = vm.envAddress("VALIDATOR_ADMIN");

        vm.startBroadcast(deployerPrivateKey);
        Validator v = new Validator();
        v.setAdmin(validatorAdmin);
        vm.stopBroadcast();

        console.log("New Validator:", address(v));
    }
}

// ── Step 1b: deploy new implementation (chain-specific) ───────────────────────

contract DeployImplEthereum is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        EthereumControllerToken impl = new EthereumControllerToken();
        vm.stopBroadcast();
        console.log("New EthereumControllerToken impl:", address(impl));
    }
}

contract DeployImplGnosis is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        GnosisControllerToken impl = new GnosisControllerToken();
        vm.stopBroadcast();
        console.log("New GnosisControllerToken impl:", address(impl));
    }
}

contract DeployImplPolygon is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        PolygonControllerToken impl = new PolygonControllerToken();
        vm.stopBroadcast();
        console.log("New PolygonControllerToken impl:", address(impl));
    }
}

// ── Step 2: print Safe calldata (no broadcast) ────────────────────────────────

/**
 * Prints the raw calldata for the two Safe transactions needed per proxy:
 *   tx1: proxy.upgradeToAndCall(newImpl, "")
 *   tx2: proxy.setValidator(newValidator)
 *
 * These can be pasted into the Safe Transaction Builder UI, or batched via MultiSend.
 *
 * Usage (no --broadcast):
 *   PROXY=<addr> IMPL=<addr> VALIDATOR=<addr> \
 *   forge script script/UpgradeV1BlockFix.s.sol:PrintSafeCalldata --rpc-url $RPC_URL -vvvv
 */
contract PrintSafeCalldata is Script {
    function run() external view {
        address proxy = vm.envAddress("PROXY");
        address impl = vm.envAddress("IMPL");
        address validatorAddr = vm.envAddress("VALIDATOR");

        bytes memory upgradeCalldata = abi.encodeCall(
            UUPSUpgradeable.upgradeToAndCall,
            (impl, "")
        );
        bytes memory setValidatorCalldata = abi.encodeCall(
            Token.setValidator,
            (validatorAddr)
        );

        console.log("=== Safe transactions for proxy:", proxy, "===");
        console.log("");
        console.log("tx1: upgradeToAndCall");
        console.log("  to  :", proxy);
        console.log("  data:", vm.toString(upgradeCalldata));
        console.log("");
        console.log("tx2: setValidator");
        console.log("  to  :", proxy);
        console.log("  data:", vm.toString(setValidatorCalldata));
    }
}
