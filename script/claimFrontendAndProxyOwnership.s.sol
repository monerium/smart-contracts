// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ControllerToken.sol";
import "../src/BlacklistValidatorUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../src/tests/tokenfrontend.sol";


contract All is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);
        console.log("Configuring with Token:");//, tokenAddress, "System:", system, "Admin:", admin, "Allowance:", allowance);


        // Assuming Token and SmartController are already deployed and their ABIs are known
        ControllerToken token = ControllerToken(tokenAddress);
        TokenFrontend frontend = TokenFrontend(token.getFrontend());

        token.acceptOwnership();
        frontend.claimOwnership();
        vm.stopBroadcast();
    }
}

