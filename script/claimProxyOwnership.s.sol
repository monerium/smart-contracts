// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Token.sol";
import "../src/BlacklistValidatorUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";


contract All is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenAddress = vm.envAddress("TOKEN");

        vm.startBroadcast(deployerPrivateKey);
        console.log("Configuring with Token:");//, tokenAddress, "System:", system, "Admin:", admin, "Allowance:", allowance);


        // Assuming Token and SmartController are already deployed and their ABIs are known
        Token token = Token(tokenAddress);

        token.acceptOwnership();
        vm.stopBroadcast();
    }
}

