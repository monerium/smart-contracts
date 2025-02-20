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
//        address admin = vm.envAddress("ADMIN");

        vm.startBroadcast(deployerPrivateKey);

        // Assuming Token and SmartController are already deployed and their ABIs are known
        Token token = Token(tokenAddress);

        token.addAdminAccount(0x982d4bfda9dd538c0abd4dED6f27Fc170F048aA9);
        token.addAdminAccount(0xEb063c49b09221C3567ce3924Ddf727f4ec3d9B2);
        token.addAdminAccount(0x63bD39AC130879203766663D0408da306C553263);

        token.addAdminAccount(0xcb124a864489382d072aaA19F715C4CD836e57bE);
        token.addAdminAccount(0x02C4D14022F7779e5f1eD4224a4BDE3e166E35F0);
        token.addAdminAccount(0x613121dE604B432751e31E5bc92bc070A1e8fD07);

        token.addAdminAccount(0x431d580632d95804Ccb74B4F2DFA22ef58eCF027);

        console.log("Admin account added successfully.");

        vm.stopBroadcast();
    }
}

