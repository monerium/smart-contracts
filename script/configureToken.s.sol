// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Token.sol";
import "../src/BlacklistValidatorUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract All is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");
        address system = vm.envAddress("SYSTEM_ADDRESS");
        address admin = vm.envAddress("ADMIN_ADDRESS");
        uint256 allowance = vm.envUint("ALLOWANCE");
        if (allowance == 0) {
            allowance = 50000000000000000000000000; // Default value if not provided
        }

        vm.startBroadcast(deployerPrivateKey);
        console.log("Configuring with Token:");//, tokenAddress, "System:", system, "Admin:", admin, "Allowance:", allowance);


        // Assuming Token and SmartController are already deployed and their ABIs are known
        Token token = Token(tokenAddress);

        token.addAdminAccount(admin);
        console.log("Admin account added successfully.");

        token.addSystemAccount(system);
        console.log("System account added successfully.");

        token.setMaxMintAllowance(allowance);
        console.log("Max mint allowance set successfully.");

        address owner = token.owner();
        if (admin == owner) {
            token.setMintAllowance(system, allowance);
            console.log("Mint allowance set successfully for system as owner.");
        }

        vm.stopBroadcast();
    }
}

