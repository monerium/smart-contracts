const { Web3 } = require("web3");
const BigNumber = require("bignumber.js");
const path = require("path");
const fs = require("fs");
const queryStep = new BigNumber(400000); // Number of blocks to query at a time

async function main(rpcURL, V2Address, startBlock, V1Address) {
  const web3 = new Web3(new Web3.providers.HttpProvider(rpcURL));
  const contract = new web3.eth.Contract(erc20ABI, V1Address);
  const latestBlock = await web3.eth.getBlockNumber();
  const holdersSet = await fetchTokenHolders(contract, startBlock, latestBlock);

  const { totalSum, holderBalances } = await fetchBalancesAndTotalSum(
    contract,
    holdersSet
  );

  const totalSupply = await fetchTokenSupply(contract);

  console.log(
    `Number of holders with balances > 0: ${Object.keys(holderBalances).length}`
  );

  console.log(
    `Total sum vs total supply: ${totalSum.toFixed()} == ${totalSupply} == ${
      totalSum.toFixed() == totalSupply
    } `
  );

  generateScript(web3, holderBalances, V2Address, V1Address);
}

async function fetchTokenHolders(contract, startBlock, latestBlock) {
  let currentBlock = new BigNumber(startBlock);
  const endBlock = new BigNumber(latestBlock);

  const holdersSet = new Set();
  while (currentBlock.lt(endBlock)) {
    let toBlock = BigNumber.min(currentBlock.plus(queryStep), endBlock);
    console.log(
      `Querying blocks ${currentBlock.toString()} to ${toBlock.toString()}...`
    );

    const events = await contract.getPastEvents("Transfer", {
      fromBlock: currentBlock.toString(),
      toBlock: toBlock.toString(),
    });

    if (holdersSet.size === 0 && events.length > 0) {
      console.log(
        `Found Transfer events in the first query. Adding holders to the set...`
      );
      console.log(`block number: ${currentBlock.toString()}`);
    }
    events.forEach((event) => {
      holdersSet.add(event.returnValues.from);
      holdersSet.add(event.returnValues.to);
    });

    currentBlock = toBlock.plus(1);
  }

  console.log("holdersSet: ", holdersSet.size);
  return holdersSet;
}
async function fetchBalanceWithRetry(contract, holder, retries = 3) {
  let attempts = 0;
  while (attempts < retries) {
    try {
      const balance = await contract.methods.balanceOf(holder).call();
      return new BigNumber(balance);
    } catch (error) {
      attempts++;
      if (attempts === retries) {
        throw error;
      }
      console.warn(
        `Attempt ${attempts} failed for holder ${holder}. Retrying...`
      );
    }
  }
}

async function fetchBalancesAndTotalSum(contract, holdersSet) {
  let totalSum = new BigNumber(0);
  const holderBalances = {};
  let iterator = 0;

  for (let holder of holdersSet) {
    if (iterator % 50 === 0) {
      console.log(`Fetching balance for holder ${iterator}...`);
    }

    try {
      const balanceBN = await fetchBalanceWithRetry(contract, holder);
      iterator++;
      if (!balanceBN.isZero()) {
        holderBalances[holder] = balanceBN;
        totalSum = totalSum.plus(balanceBN);
      }
    } catch (error) {
      console.error(
        `Failed to fetch balance for holder ${holder} after multiple attempts.`
      );
    }
  }

  return { totalSum, holderBalances };
}

async function fetchTokenSupply(contract) {
  return await contract.methods.totalSupply().call();
}

function orderHoldersByAmount(holders) {
  return Object.entries(holders).sort(([, a], [, b]) => b - a);
}

async function generateScript(web3, holders, newToken, target) {
  const orderedHolders = orderHoldersByAmount(holders);

  let mints = orderedHolders
    .map(([address, balances]) => {
      return `        token.mint(${address}, ${balances.toFixed()});`;
    })
    .join("\n");

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
        address tokenAddress = ${web3.utils.toChecksumAddress(newToken)};
        address targetAddress = ${web3.utils.toChecksumAddress(target)};
        address devKey = vm.addr(deployerPrivateKey);
        
        vm.startBroadcast(deployerPrivateKey);
  
        // Assuming Token and SmartController are already deployed and their ABIs are known
        Token token = Token(tokenAddress);
        ERC20 target = ERC20(targetAddress);
        
        // Set Admin And System
        console.log("Setting dev key as admin and system");
        token.addAdminAccount(devKey);
        token.addSystemAccount(devKey);

        token.setMaxMintAllowance(target.totalSupply());
        token.setMintAllowance(devKey, target.totalSupply());
        console.log("mint allowance set successfully.");

${mints}

        console.log("minting completed successfully.");
        require(token.totalSupply() == target.totalSupply(), "balances are not fully copied.");
        console.log("balances are fully copied");
        
        console.log("removing dev key as admin and system");
        token.removeAdminAccount(devKey);
        token.removeSystemAccount(devKey);
        vm.stopBroadcast();
    }
}`;

  // Write the Solidity script to a file
  const outputPath = path.join(__dirname, `BatchMint-${target}.s.sol`);
  fs.writeFileSync(outputPath, solidityContent, "utf8");
  console.log(
    `Solidity script BatchMint.sol has been generated at ${outputPath}.`
  );
}

const erc20ABI = [
  {
    constant: true,
    inputs: [{ name: "_owner", type: "address" }],
    name: "balanceOf",
    outputs: [{ name: "balance", type: "uint256" }],
    payable: false,
    stateMutability: "view",
    type: "function",
  },
  {
    constant: true,
    inputs: [],
    name: "totalSupply",
    outputs: [{ name: "", type: "uint256" }],
    payable: false,
    stateMutability: "view",
    type: "function",
  },
  {
    anonymous: false,
    inputs: [
      { indexed: true, name: "from", type: "address" },
      { indexed: true, name: "to", type: "address" },
      { indexed: false, name: "value", type: "uint256" },
    ],
    name: "Transfer",
    type: "event",
  },
];

if (process.argv.length < 6) {
  console.error(
    "Usage: node script.js <rpcURL> <V2Address> <startBlock> <V1Address> "
  );
  process.exit(1);
}

main(process.argv[2], process.argv[3], process.argv[4], process.argv[5]);
