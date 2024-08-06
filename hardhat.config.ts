import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
//Compatibility with Foundry
import "hardhat-preprocessor";
import fs from "fs";
//Add-on for Upgradable contract
import "@openzeppelin/hardhat-upgrades";
import "hardhat-gas-reporter";
import "./tasks/deploy";
import "./tasks/validate";
import "./tasks/validateUpgrade";

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  preprocess: {
    eachLine: (hre) => ({
      transform: (line: string) => {
        if (line.match(/^\s*import /i)) {
          for (const [from, to] of getRemappings()) {
            if (line.includes(from)) {
              line = line.replace(from, to);
              break;
            }
          }
        }
        return line;
      },
    }),
  },
  paths: {
    sources: "./src",
    cache: "./cache_hardhat",
  },
  gasReporter: {
    currency: "EUR",
    gasPrice: 21,
    enabled: true,
  },
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
      // You can specify additional properties like accounts here if needed
    },
    // You can add other network configurations here
  },
};

function getRemappings() {
  return fs
    .readFileSync("remappings.txt", "utf8")
    .split("\n")
    .filter(Boolean) // remove empty lines
    .map((line) => line.trim().split("="));
}

export default config;
