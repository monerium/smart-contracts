// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Token.sol";
import "../src/TokenV2.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract UpgradeTokenToV2 is Script {
    function run() external {
        // Load the deployer private key from the environment or specify it directly
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAddress = vm.envAddress("PROXY");

        // Start the broadcast using the deployer's private key
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the new TokenV2 implementation contract
        TokenV2 newTokenV2Implementation = new TokenV2();

        // Upgrade the proxy to use the new implementation contract
        UUPSUpgradeable proxy = UUPSUpgradeable(proxyAddress);

        // Get the function selector for initializeV2
        bytes memory data = abi.encodeWithSelector(
            newTokenV2Implementation.initializeV2.selector
        );

        // Upgrade the proxy to use the new implementation contract and call initializeV2
        proxy.upgradeToAndCall(address(newTokenV2Implementation), data);

        // End the broadcast
        vm.stopBroadcast();
    }
}
