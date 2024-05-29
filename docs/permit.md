# Smart Contract Permit Function Tutorial

Developers should use [ERC-2612 Permit](https://eips.ethereum.org/EIPS/eip-2612) instead of [ERC-20 Approve](https://eips.ethereum.org/EIPS/eip-20) because it allows for gasless token approvals through off-chain signatures, eliminating the need for a separate on-chain approval transaction. This not only reduces transaction costs but also streamlines user experience by enabling approvals and transfers to happen in a single transaction. By using Permit, developers can create more efficient and user-friendly applications, enhancing security and flexibility within the Ethereum ecosystem.

This tutorial breaks down the use of the permit function into digestible steps.

## Step 1: Import Required Modules
Import the SigningKey module to sign the permit digest.

```js
const { SigningKey } = require("@ethersproject/signing-key");
```

## Step 2: Instantiate the Smart Contract Instances
Create instances of the smart contracts by using the ABI and address. Obtain the controller address through the instantiated EUR contract.

```js
const { ethers } = require("ethers");

// EUR contract instantiation
const tokenABI = [...] // token ABI goes here
const tokenProxyAddress = "<token_proxy_contract_address>";
const token = new ethers.Contract(tokenProxyAddress, tokenABI, signer);
```
	
## Step 3: Prepare the Permit Details
Define the nonce and deadline for the permit function.
```js
const nonce = await token.nonce(<yourAddress>);
const deadline = Math.floor(Date.now() / 1000) + 60 * 60; // 1 hour from now
```

## Step 4: Create the Permit Digest
Generate the digest that the permit function will use for transaction verification.
```js
const digest = await token.getPermitDigest(
  <yourAddress>,
  <spenderAddress>,
  <value>,
  nonce,
  deadline
);
```

## Step 5: Sign the Digest
Use your private key to sign the digest. This signature proves that you have authorized the transaction.
```js
const signingKey = new SigningKey(<yourPrivateKey>);
const signature = signingKey.signDigest(digest);
```

## Step 6: Submit the Permit Transaction
Complete the process by submitting the permit function with the required parameters and the signature.
```js
await token.permit(
  <yourAddress>,
  <spenderAddress>,
  <value>,
  <deadline>,
  signature.v,
  signature.r,
  signature.s
);
```

## Full Code 
```js
const { ethers } = require("ethers");
const { SigningKey } = require("@ethersproject/signing-key");

// Replace the following with your contract's ABI and addresses
const tokenABI = [...] // token ABI goes here
const tokenProxyAddress = "<token_proxy_contract_address>"; // token Proxy contract address
const rpc = "http://<your_rpc>"

async function permitFunction(yourAddress, spenderAddress, value, yourPrivateKey) {
  // Provider and signer would be set up here (e.g., using ethers.js)
  const provider = new ethers.providers.JsonRpcProvider(rpc);
  const signer = new ethers.Wallet(yourPrivateKey, provider);

  // Instantiate the contracts
  const token = new ethers.Contract(tokenProxyAddress, tokenABI, signer);

  // Prepare the permit details
  const nonce = await token.nonce(yourAddress);
  const deadline = Math.floor(Date.now() / 1000) + 60 * 60; // 1 hour from now

  // Create the permit digest
  const digest = await token.getPermitDigest(
    yourAddress,
    spenderAddress,
    value,
    nonce,
    deadline
  );

  // Sign the digest
  const signingKey = new SigningKey(yourPrivateKey);
  const signature = signingKey.signDigest(digest);

  // Submit the permit transaction
  const tx = await token.permit(
    yourAddress,
    spenderAddress,
    value,
    deadline,
    signature.v,
    signature.r,
    signature.s
  );

  return tx;
}

// Usage: call permitFunction with the required parameters
// permitFunction(<yourAddress>, <spenderAddress>, <value>, <yourPrivateKey>).then(...);

```
