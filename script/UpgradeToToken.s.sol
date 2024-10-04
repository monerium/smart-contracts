// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/controllers/GnosisControllerToken.sol";
import "../src/controllers/PolygonControllerToken.sol";
import "../src/controllers/EthereumControllerToken.sol";
import "../src/Token.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract DefaultToken is Script {
    function run() external {
        // Load the deployer private key and proxy address from the environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAddress = vm.envAddress("PROXY");

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the new Token implementation contract
        Token newImplementation = new Token();

        // Initialize the proxy contract
        UUPSUpgradeable proxy = UUPSUpgradeable(proxyAddress);

        bytes memory data = "";
        // Upgrade the proxy to use the new implementation contract
        proxy.upgradeToAndCall(address(newImplementation), data);

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}

contract Gnosis is Script {
    function run() external {
        // Load the deployer private key and proxy address from the environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAddress = vm.envAddress("PROXY");

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the new GnosisControllerToken implementation contract
        GnosisControllerToken newImplementation = new GnosisControllerToken();

        // Initialize the proxy contract
        UUPSUpgradeable proxy = UUPSUpgradeable(proxyAddress);

        bytes memory data = "";
        // Upgrade the proxy to use the new implementation contract
        proxy.upgradeToAndCall(address(newImplementation), data);

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}

contract Ethereum is Script {
    function run() external {
        // Load the deployer private key and proxy address from the environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAddress = vm.envAddress("PROXY");

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the new EthereumControllerToken implementation contract
        EthereumControllerToken newImplementation = new EthereumControllerToken();

        // Initialize the proxy contract
        UUPSUpgradeable proxy = UUPSUpgradeable(proxyAddress);

        bytes memory data = "";
        // Upgrade the proxy to use the new implementation contract
        proxy.upgradeToAndCall(address(newImplementation), data);

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}

contract Polygon is Script {
    function run() external {
        // Load the deployer private key and proxy address from the environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAddress = vm.envAddress("PROXY");

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the new PolygonControllerToken implementation contract
        PolygonControllerToken newImplementation = new PolygonControllerToken();

        // Initialize the proxy contract
        UUPSUpgradeable proxy = UUPSUpgradeable(proxyAddress);

        bytes memory data = "";
        // Upgrade the proxy to use the new implementation contract
        proxy.upgradeToAndCall(address(newImplementation), data);

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
