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
        address wallet = vm.envAddress("WALLET_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        Token token = Token(tokenAddress);

        token.removeAdminAccount(wallet);
        console.log("Admin account removed successfully.");

        token.removeSystemAccount(wallet);
        console.log("System account removed successfully.");

        vm.stopBroadcast();
    }
}

