// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/BlacklistValidatorUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract All is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address validatorAddress = vm.envAddress("VALIDATOR");
        address admin = vm.envAddress("ADMIN");

        vm.startBroadcast(deployerPrivateKey);

        BlacklistValidatorUpgradeable validator = BlacklistValidatorUpgradeable(validatorAddress);

        validator.removeAdminAccount(admin);
        console.log("Admin account added successfully.");

        vm.stopBroadcast();
    }
}

