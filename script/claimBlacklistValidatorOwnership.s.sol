// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/BlacklistValidatorUpgradeable.sol";


contract All is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address Address = vm.envAddress("ADDRESS");

        vm.startBroadcast(deployerPrivateKey);


        // Assuming Token and SmartController are already deployed and their ABIs are known
        BlacklistValidatorUpgradeable validator = BlacklistValidatorUpgradeable(Address);

        validator.acceptOwnership();
        vm.stopBroadcast();
    }
}

