const { Web3 } = require("web3");
const BigNumber = require("bignumber.js");
const path = require("path");
const fs = require("fs");
const queryStep = new BigNumber(400000); // Number of blocks to query at a time

async function fetchTokenHolders(contract, startBlock, latestBlock) {
  let currentBlock = new BigNumber(startBlock);
  const endBlock = new BigNumber(latestBlock);

  const holdersSet = new Set();
  while (currentBlock.lt(endBlock)) {
    let toBlock = BigNumber.min(currentBlock.plus(queryStep), endBlock);
    console.log(
      `Querying blocks ${currentBlock.toString()} to ${toBlock.toString()}...`
    );

    const eventsBan = await contract.getPastEvents("Ban", {
      fromBlock: currentBlock.toString(),
      toBlock: toBlock.toString(),
    });

    const eventsUnban = await contract.getPastEvents("Unban", {
      fromBlock: currentBlock.toString(),
      toBlock: toBlock.toString(),
    });

    eventsBan.forEach((event) => {
      console.log("Ban event: ", event.returnValues.adversary);
      holdersSet.add(event.returnValues.adversary);
    });

    eventsUnban.forEach((event) => {
      console.log("Unban event: ", event.returnValues.friend);
      holdersSet.delete(event.returnValues.friend);
    });
    currentBlock = toBlock.plus(1);
  }

  return holdersSet;
}

async function generateScript(web3, addresses, owner, contract) {
  const addressArray = Array.from(addresses);
  let bans = addressArray
    .map((address) => {
      return `        validator.ban(${address});`;
    })
    .join("\n");

  let solidityContent = `// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/BlacklistValidatorUpgradeable.sol";

contract BatchMint is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address devKey = vm.addr(deployerPrivateKey);
        address validatorAddress = ${web3.utils.toChecksumAddress(contract)};
        
        vm.startBroadcast(deployerPrivateKey);
        BlacklistValidatorUpgradeable validator = BlacklistValidatorUpgradeable(validatorAddress); 
  
        // Adding Admin role to the dev key
        validator.addAdminAccount(devKey);
${bans}
        console.log("banning completed successfully.");
        validator.removeAdminAccount(devKey);
        validator.transferOwnership(${web3.utils.toChecksumAddress(owner)});
        vm.stopBroadcast();
    }
}`;

  // Write the Solidity script to a file
  const outputPath = path.join(__dirname, `BatchBan-${contract}.s.sol`);
  fs.writeFileSync(outputPath, solidityContent, "utf8");
  console.log(
    `Solidity script BatchBan.sol has been generated at ${outputPath}.`
  );
}
async function main(rpcURL, target, owner, startBlock) {
  const web3 = new Web3(new Web3.providers.HttpProvider(rpcURL));
  const contract = new web3.eth.Contract(BlacklistValidatorABI, target);
  const latestBlock = await web3.eth.getBlockNumber();

  const holdersSet = await fetchTokenHolders(contract, startBlock, latestBlock);
  await generateScript(web3, holdersSet, owner, target);
}

if (process.argv.length < 6) {
  console.error(
    "Usage: node script.js <rpcURL> <validator_Address> <final_owner> <startBlock>"
  );
  process.exit(1);
}

const BlacklistValidatorABI = [
  {
    constant: false,
    inputs: [{ name: "_token", type: "address" }],
    name: "reclaimToken",
    outputs: [],
    payable: false,
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    constant: false,
    inputs: [{ name: "_contractAddr", type: "address" }],
    name: "reclaimContract",
    outputs: [],
    payable: false,
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    constant: false,
    inputs: [],
    name: "claimOwnership",
    outputs: [],
    payable: false,
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    constant: false,
    inputs: [],
    name: "renounceOwnership",
    outputs: [],
    payable: false,
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    constant: true,
    inputs: [],
    name: "owner",
    outputs: [{ name: "", type: "address" }],
    payable: false,
    stateMutability: "view",
    type: "function",
  },
  {
    constant: false,
    inputs: [{ name: "adversary", type: "address" }],
    name: "ban",
    outputs: [],
    payable: false,
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    constant: false,
    inputs: [],
    name: "reclaimEther",
    outputs: [],
    payable: false,
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    constant: false,
    inputs: [
      { name: "from", type: "address" },
      { name: "to", type: "address" },
      { name: "amount", type: "uint256" },
    ],
    name: "validate",
    outputs: [{ name: "valid", type: "bool" }],
    payable: false,
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    constant: false,
    inputs: [{ name: "friend", type: "address" }],
    name: "unban",
    outputs: [],
    payable: false,
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    constant: true,
    inputs: [
      { name: "_from", type: "address" },
      { name: "_value", type: "uint256" },
      { name: "_data", type: "bytes" },
    ],
    name: "tokenFallback",
    outputs: [],
    payable: false,
    stateMutability: "pure",
    type: "function",
  },
  {
    constant: true,
    inputs: [],
    name: "pendingOwner",
    outputs: [{ name: "", type: "address" }],
    payable: false,
    stateMutability: "view",
    type: "function",
  },
  {
    constant: false,
    inputs: [{ name: "newOwner", type: "address" }],
    name: "transferOwnership",
    outputs: [],
    payable: false,
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    constant: true,
    inputs: [{ name: "", type: "address" }],
    name: "blacklist",
    outputs: [{ name: "", type: "bool" }],
    payable: false,
    stateMutability: "view",
    type: "function",
  },
  { payable: false, stateMutability: "nonpayable", type: "fallback" },
  {
    anonymous: false,
    inputs: [{ indexed: true, name: "adversary", type: "address" }],
    name: "Ban",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [{ indexed: true, name: "friend", type: "address" }],
    name: "Unban",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [{ indexed: true, name: "previousOwner", type: "address" }],
    name: "OwnershipRenounced",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      { indexed: true, name: "previousOwner", type: "address" },
      { indexed: true, name: "newOwner", type: "address" },
    ],
    name: "OwnershipTransferred",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      { indexed: true, name: "from", type: "address" },
      { indexed: true, name: "to", type: "address" },
      { indexed: false, name: "amount", type: "uint256" },
      { indexed: false, name: "valid", type: "bool" },
    ],
    name: "Decision",
    type: "event",
  },
];

main(process.argv[2], process.argv[3], process.argv[4], process.argv[5]);
