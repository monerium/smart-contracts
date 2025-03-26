#!/usr/bin/env node

// Script to derive Ethereum public address from private key
// Uses ethers.js v6.7.1

const { Wallet } = require("ethers");

async function getAddressFromPrivateKey() {
  try {
    // Get the private key from environment variable
    const privateKey = process.env.PRIVATE_KEY;

    if (!privateKey) {
      console.error("Error: PRIVATE_KEY environment variable is not set");
      process.exit(1);
    }

    // Create a wallet instance from the private key
    // ethers v6 handles keys with or without 0x prefix
    const wallet = new Wallet(privateKey);

    // Get the public address
    const address = await wallet.getAddress();

    // Print the address (without exposing the private key)
    console.log(address);
  } catch (error) {
    process.exit(1);
  }
}

// Execute the function
getAddressFromPrivateKey();
