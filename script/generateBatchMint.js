const fs = require("fs");
const path = require("path");
const Web3 = require("web3");

// Initialize Web3
const web3 = new Web3();

// Verify command line arguments
if (process.argv.length !== 5) {
  console.log(
    "Usage: node generateBatchMint.js <tokenAddress> <targetAddress> <path_to_csv_file>"
  );
  process.exit(1);
}

// Extract command line arguments
const [tokenAddress, targetAddress, csvFilePath] = process.argv.slice(2);

// Validate CSV file existence
if (!fs.existsSync(csvFilePath)) {
  console.log("CSV file does not exist.");
  process.exit(1);
}

// Read CSV file and skip the first line
const csvData = fs.readFileSync(csvFilePath, "utf8").split("\n").slice(1);

// Extract addresses and convert them to checksum addresses, removing any quotes
const addresses = csvData
  .map((line) => {
    const [address] = line.split(",");
    if (!address || address.trim() === "") return null; // Skip empty lines or addresses
    try {
      return web3.utils.toChecksumAddress(address.replace(/\"/g, ""));
    } catch (error) {
      console.error(
        `Skipping invalid address: ${address}. Error: ${error.message}`
      );
      return null;
    }
  })
  .filter(Boolean); // Remove null values resulting from skipped lines
const count = addresses.length;

// Initialize the recipients string
let recipientsString = addresses
  .map((address, index) => {
    // Append a comma to all but the last address
    return `            ${address}${index < addresses.length - 1 ? "," : ""}`;
  })
  .join("\n");

// Create the Solidity file content
let solidityContent = `// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Token.sol";
import "../src/BlacklistValidatorUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BatchMint is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenAddress = ${web3.utils.toChecksumAddress(tokenAddress)};
        address targetAddress = ${web3.utils.toChecksumAddress(targetAddress)};
        address[${count}] memory recipients = [
${recipientsString}
        ];

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
        bool success = token.totalSupply() == target.totalSupply();
        console.log("balances are fully copied: ", success);
        vm.stopBroadcast();
    }
}`;

// Write the Solidity script to a file
const outputPath = path.join(__dirname, `BatchMint-${targetAddress}.s.sol`);
fs.writeFileSync(outputPath, solidityContent, "utf8");
console.log(
  `Solidity script BatchMint.sol has been generated at ${outputPath}.`
);
