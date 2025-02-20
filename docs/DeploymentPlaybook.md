# Token Deployment Playbook

This document provides a comprehensive guide for deploying and configuring tokens in various environments. Please follow each section sequentially to ensure a successful deployment.

## Prerequisites

Before beginning the deployment process, ensure you have:

- A new Externally Owned Account (EOA) 
- Sufficient native tokens in your EOA to cover deployment costs
- Access to the required environment variables and API keys
  - JSON-RPC URL
  - Blockchain explorer API Key and API URL (if required)
  - Chain ID (if required)

## Environment Setup

1. Navigate to the `smart-contracts` directory and ensure you're on the `main` branch

2. Configure the following essential environment variables:

```

PRIVATE_KEY=<your-private-key>

RPC_URL=<network-rpc-endpoint>

```

## Deployment Process

### 1. Contract Deployment and Verification

The verification process can vary depending on the chain you're deploying to. Some chains require only the blockchain explorer scan API URL, an API key, and the chain ID to work, while others might need more custom configuration. Let's explore the common deployment patterns through examples.

Most deployments on Ethereum-like chains can be done with this basic command:

```bash

PRIVATE_KEY=<key> forge script script/deploy.s.sol:All --rpc-url $RPC_URL --broadcast --etherscan-api-key $ETHERSCAN_API_KEY --legacy

```

Other chains may require additional parameters, you'll need to include the direct link to the blockchain explorer API, its API key, and the chain ID:

```bash

PRIVATE_KEY=<key> forge script script/deploy.s.sol:All --rpc-url $RPC_URL --broadcast --etherscan-api-key $POLYGONSCAN_API_KEY --verify --verifier-url $POLYGONSCAN_URL --chain-id $POLYGON_CHAIN_ID --legacy

```

For networks using Blockscout, the process is typically more straightforward since they don't enforce API keys. You'll only need to specify the API URL, chain ID, and the `verifier`:

```bash

PRIVATE_KEY=<key> forge script script/deploy.s.sol:All --rpc-url $RPC_URL --broadcast --verify --verifier blockscout --verifier-url $GNOSIS_CHIADO_BLOCKSCOUT_URL --chain-id $GNOSIS_CHIADO_CHAIN_ID --legacy

```

Linea May require you too add additional configurations because the chain is unknown to foundry. You should add this configuration to your `foundry.toml`

```toml
[etherscan]
unknown_chain = { key = "${LINEASCAN_API_KEY}", chain = 59141, url = "https://api-sepolia.lineascan.build/api" }
```

> This configuration is for Linea Sepolia, you should replace the `url` if you're deploying on mainnet

After successful deployment, your tokens should be verified and visible on the blockchain explorer!

> The logs will print you the newly deployed token addresses

### 2. Token Configuration

After successful deployment, configure the token with the following parameters:

- System Accounts

- Admin Accounts

- Maximum Mint Allowance

- Mint Allowance per System Account

Use the configuration script with this syntax:

```bash

  PRIVATE_KEY=<key> sh script/configureToken.sh \

$RPC_URL \

$TOKEN_ADDRESS \

$MAX_ALLOWANCE \

$ALLOWANCE_PER_SYSTEM \

$SYSTEM_ADDRESS \

$ADMIN1_ADDRESS \

[$ADMIN2_ADDRESS] \

[$ADMIN3_ADDRESS] \

[...] \

[$ADMIN10_ADDRESS] \

```

**Important Note**: The MaxAllowance and Allowance values should be provided in EURe units. The script will automatically convert these to wei before transaction submission.

Example configuration:

```bash

PRIVATE_KEY=<key> sh script/configureToken.sh \

$RPC_URL \

0xTokenAddress \

3000000 \

500000 \

0x1System \

0x2Admin \

0x3Admin

```

### 3. Ownership Transfer

The ownership transfer process consists of two steps:

1. Initiate the transfer:

```bash

PRIVATE_KEY=<key> TOKEN=<token_address> OWNER=<final_owner> \

forge script script/transferOwnership.s.sol \

--broadcast \

--rpc-url $RPC_URL \

--legacy

```

2. Complete the transfer using one of these methods:

- Call `acceptOwnership` directly from the multi-sig safe

- OR execute the claim script with the final owner's private key:

```bash

PRIVATE_KEY=<final_owner_key> TOKEN=<token_address> \

forge script script/claimProxyOwnership.s.sol \

--broadcast \

--rpc-url $RPC_URL \

--legacy

```

## Verification Checklist

After completing the deployment process, verify:

- [ ] Contracts are verified on the blockchain explorer

- [ ] System accounts are properly configured

- [ ] Admin accounts are set up correctly

- [ ] Maximum mint allowance is set to the desired value

- [ ] Per-system mint allowances are configured

- [ ] Ownership has been successfully transferred to the final owner

# Tips

The realms of blockchain can sometimes be funky and random, things may not go as planned. To help us in those troubled times, here are some useful flags to know.

## Setting Gas Price

When you need to take control of your transaction costs:

```bash

forge script [...] --with-gas-price <priceInWei>

```

For example:

```bash

PRIVATE_KEY=$PRIVATE_KEY forge script script/deploy.s.sol:All \

--rpc-url $RPC_URL \

--broadcast \

--with-gas-price 2000000000

```

## Taking It Slow

Sometimes, the network can cause some turbulence and you may want to go one transaction at a time:

```bash

forge script [...] --slow

```

For example:

```bash

PRIVATE_KEY=$PRIVATE_KEY forge script script/deploy.s.sol:All \

--rpc-url $RPC_URL \

--broadcast \

--slow

```

## Forcing the Hand of the Verifier

If the verifier tends to fail but you're sure about your API, API-KEY and chain ID, sometimes all it takes is patience and perseverance:

```bash

forge script [...] --verify --retries 5 --delay 2

```

For example:

```bash

PRIVATE_KEY=$PRIVATE_KEY forge script script/deploy.s.sol:EUR \

--rpc-url $RPC_URL \

--broadcast \

--etherscan-api-key $ETHERSCAN_API_KEY \

--verify $VERIFIER_URL \

--retries 5 \

--delay 2

```

## Resuming Unfinished Scripts

Not enough tokens, internet issues, or some other problem stopped your script? Fear not since we can continue where we stopped using the `resume` flag.

If you've launched this command but it stopped unfinished:

```bash

PRIVATE_KEY=$PRIVATE_KEY forge script script/deploy.s.sol:EUR \

--rpc-url $RPC_URL \

--broadcast

```

Resume it by running:

```bash

PRIVATE_KEY=$PRIVATE_KEY forge script script/deploy.s.sol:EUR \

--rpc-url $RPC_URL \

--broadcast \

--resume

```

### Future Transaction Tries to Replace Pending

This is a known bug that can arrive on any chain. The best path is to combine `--resume` and `--slow`:

```bash

PRIVATE_KEY=$PRIVATE_KEY forge script script/deploy.s.sol:EUR \

--rpc-url $RPC_URL \

--broadcast \

--slow \

--resume

```
