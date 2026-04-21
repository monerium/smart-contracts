// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Validator.sol";

/**
 * Deploys a new Validator and grants ADMIN_ROLE to VALIDATOR_ADMIN.
 *
 * Required env vars:
 *   PRIVATE_KEY      - deployer private key
 *   VALIDATOR_ADMIN  - address to grant ADMIN_ROLE on the new Validator
 *
 * Run once per chain. Capture the printed validator address and set VALIDATOR=<addr>
 * before running UpgradeV1BlockFix.s.sol for each token proxy.
 */
contract DeployValidator is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address validatorAdmin = vm.envAddress("VALIDATOR_ADMIN");

        vm.startBroadcast(deployerPrivateKey);

        Validator validator = new Validator();
        validator.setAdmin(validatorAdmin);

        vm.stopBroadcast();

        console.log("New Validator deployed at:", address(validator));
    }
}
