// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ControllerToken.sol";
import "../src/tests/TokenFrontend.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract All is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");
        address frontendAddress = vm.envAddress("FRONTEND_ADDRESS");
        address owner = vm.envAddress("OWNER_ADDRESS");
        vm.startBroadcast(deployerPrivateKey);
        console.log("Configuring with Token:");

        // Assuming Token and SmartController are already deployed and their ABIs are known
        ControllerToken token = ControllerToken(tokenAddress);
        TokenFrontend frontend = TokenFrontend(frontendAddress);

        // Claiming ownership of Token and SmartController
        if (token.pendingOwner() == address(this)) {
            token.acceptOwnership();
        }
        //        frontend.claimOwnership();

        // Connecting Token proxy as a controller.
        frontend.setController(tokenAddress);

        // Transfer ownership of Token and TokenFrontend to the new owner
        frontend.transferOwnership(owner);
        token.transferOwnership(owner);

        vm.stopBroadcast();
    }
}

