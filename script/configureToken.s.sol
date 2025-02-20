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
        uint256 MaxAllowance = vm.envUint("MAX_MINT_ALLOWANCE");
        address devKey = vm.addr(deployerPrivateKey);
        uint256 allowance = vm.envUint("MINT_ALLOWANCE");

        // Convert values from ether to wei before the max check
        MaxAllowance = MaxAllowance * 1e18;
        allowance = allowance * 1e18;
        
        // Get the number of admins from environment
        uint256 adminCount = vm.envUint("ADMIN_COUNT");
        
        // After conversion, check if we want max values
        if (MaxAllowance == 1e18) { // 1 ether in wei
            MaxAllowance = type(uint256).max;
        }
        if (allowance == 1e18) { // 1 ether in wei
            allowance = type(uint256).max;
        }

        vm.startBroadcast(deployerPrivateKey);
        console.log("Configuring Token with admins");
        console.log("Max Allowance (wei):", MaxAllowance);
        console.log("Mint Allowance (wei):", allowance);
        
        Token token = Token(tokenAddress);
        
        // Add all admin accounts
        for (uint256 i = 0; i < adminCount; i++) {
            string memory adminVar = string(abi.encodePacked("ADMIN_ADDRESS_", vm.toString(i)));
            address admin = vm.envAddress(adminVar);
            token.addAdminAccount(admin);
            console.log("Admin account added successfully:", admin);
        }

        token.addSystemAccount(system);
        console.log("System account added successfully.");
        token.setMaxMintAllowance(MaxAllowance);
        console.log("Max mint allowance set successfully.");
        token.addAdminAccount(devKey);
        token.setMintAllowance(system, allowance);
        console.log("mint allowance set successfully.");
        
        if (devKey != vm.envAddress("ADMIN_ADDRESS_0")) {
            token.removeAdminAccount(devKey);
        }
        
        vm.stopBroadcast();
    }
}
