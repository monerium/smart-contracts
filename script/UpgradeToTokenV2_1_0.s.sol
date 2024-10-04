// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Token.sol";
import "../src/v2_1_0/GnosisControllerTokenV2_1_0.sol";
import "../src/v2_1_0/PolygonControllerTokenV2_1_0.sol";
import "../src/v2_1_0/EthereumControllerTokenV2_1_0.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract Gnosis is Script {
    function run() external {
        // Load the deployer private key from the environment or specify it directly
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAddress = vm.envAddress("PROXY");

        // Start the broadcast using the deployer's private key
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the new TokenV2 implementation contract
        GnosisControllerTokenV2_1_0 newTokenV2Implementation = new GnosisControllerTokenV2_1_0();

        // Upgrade the proxy to use the new implementation contract
        UUPSUpgradeable proxy = UUPSUpgradeable(proxyAddress);

        bytes memory data = "";
        // Upgrade the proxy to use the new implementation contract and call initializeV2
        proxy.upgradeToAndCall(address(newTokenV2Implementation), data);

        // End the broadcast
        vm.stopBroadcast();
    }
}

contract Polygon is Script {
    function run() external {
        // Load the deployer private key from the environment or specify it directly
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAddress = vm.envAddress("PROXY");

        // Start the broadcast using the deployer's private key
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the new TokenV2 implementation contract
        PolygonControllerTokenV2_1_0 newTokenV2Implementation = new PolygonControllerTokenV2_1_0();

        // Upgrade the proxy to use the new implementation contract
        UUPSUpgradeable proxy = UUPSUpgradeable(proxyAddress);

        bytes memory data = "";
        // Upgrade the proxy to use the new implementation contract and call initializeV2
        proxy.upgradeToAndCall(address(newTokenV2Implementation), data);

        // End the broadcast
        vm.stopBroadcast();
    }
}

contract Ethereum is Script {
    function run() external {
        // Load the deployer private key from the environment or specify it directly
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAddress = vm.envAddress("PROXY");

        // Start the broadcast using the deployer's private key
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the new TokenV2 implementation contract
        EthereumControllerTokenV2_1_0 newTokenV2Implementation = new EthereumControllerTokenV2_1_0();

        // Upgrade the proxy to use the new implementation contract
        UUPSUpgradeable proxy = UUPSUpgradeable(proxyAddress);

        bytes memory data = "";
        // Upgrade the proxy to use the new implementation contract and call initializeV2
        proxy.upgradeToAndCall(address(newTokenV2Implementation), data);

        // End the broadcast
        vm.stopBroadcast();
    }
}
