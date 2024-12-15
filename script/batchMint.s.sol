// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Token.sol";
import "../src/BlacklistValidatorUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BatchMinter is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenAddress = 0xd58C5Db52B5B3Eb24EE38AF287d2cb0F424172A5;
        address targetAddress = 0xd58C5Db52B5B3Eb24EE38AF287d2cb0F424172A5;
        address[1] memory recipients = [0xd58C5Db52B5B3Eb24EE38AF287d2cb0F424172A5];

        vm.startBroadcast(deployerPrivateKey);

        // Assuming Token and SmartController are already deployed and their ABIs are known
        Token token = Token(tokenAddress);
        ERC20 target = ERC20(targetAddress);

        token.setMaxMintAllowance(target.totalSupply());
        token.setMintAllowance(targetAddress, target.totalSupply());
        console.log("mint allowance set successfully.");

        for (uint256 i = 0; i < recipients.length; i++) {
            token.mint(recipients[i], target.balanceOf(recipients[i]));
        }

        console.log("minting completed successfully.");
        bool success = token.getMintAllowance(targetAddress) == 0;
        console.log("mint allowance is 0: ", success);
        vm.stopBroadcast();
    }
}

