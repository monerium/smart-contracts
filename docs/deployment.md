# Deploying Monerium's E-money Token
## Requirements

* Node 18.17.0

```
git clone git@github.com:monerium/smart-contracts-v2
cd smart-contract-v2
nvm use
npm i -g yarn@1.22.21 # Install yarn
```

## Setup

Before you can compile and test the contracts, you need to install the necessary dependencies. Run the following commands:

```bash
yarn install
forge install
```

## Compilation and Testing

We use Forge for compiling and testing our smart contracts, and Hardhat for upgradability tests and deployment. Here are the steps to follow:

### Compilation

To compile the contracts, use the Forge command:

```bash
forge compile
```

### Testing

To run the tests, use the Forge command:

```bash
forge test
```

### Upgradability Testing

For Hardhat tests related to upgradability and deployment, use the following command:

```bash
npx hardhat test
```

## Deployment and Upgrades

### Token Deployment hardhat Task (un-optimized)
The deploy task allows for the flexible deployment of specified tokens. It can deploy a list of tokens provided as arguments, or all tokens if no arguments are specified. The task includes a confirmation step before proceeding with deployment.

To run the deployment task, use the command:

```bash
npx hardhat deploy [token1 token2 ...]
```

For example, to deploy only EUR and GBP tokens, use:

```bash
npx hardhat deploy eur gbp
```

To deploy all available tokens, simply run:

```bash
npx hardhat deploy
```

### Token Deployment foundry script (optimized)
Our smart contract deployment script offers multiple options for deploying tokens. It leverages an optimized approach by using a single implementation contract for all tokens, which is more efficient and cost-effective.

#### Preparing for Deployment
Before running any deployment script, ensure you have the correct environment variables set:

1. Copy your .env file to .env.local:
```shell
cp .env .env.local
```
2. Edit .env.local to include necessary variables 
3. Source the `.env.local` file to load the environment variables:
```shell
source .env.local
```

#### Run validation
Validates the implementation contract for upgradability without deploying it.
```shell
npm run validate
```

#### Deploying All Tokens
To deploy all tokens (GBP, ISK, EUR, USD) using a single implementation, use the following command:
```shell 
forge script script/deploy.s.sol:All --rpc-url $RPC_URL --broadcast --etherscan-api-key $ETHERSCAN_API_KEY --verify -vvvv

```
#### Deploying individual Tokens
To deploy each token individually, with each its own implementation contract, use the corresponding commands:

##### EUR
```shell
forge script script/deploy.s.sol:EUR --rpc-url $RPC_URL --broadcast --etherscan-api-key $ETHERSCAN_API_KEY --verify -vvvv
```
##### GBP
```shell 
forge script script/deploy.s.sol:GBP --rpc-url $RPC_URL --broadcast --etherscan-api-key $ETHERSCAN_API_KEY --verify -vvvv
```
##### ISK
```shell
forge script script/deploy.s.sol:ISK --rpc-url $RPC_URL --broadcast --etherscan-api-key $ETHERSCAN_API_KEY --verify -vvvv

```
##### USD
```shell
forge script script/deploy.s.sol:USD --rpc-url $RPC_URL --broadcast --etherscan-api-key $ETHERSCAN_API_KEY --verify -vvvv

```
#### Understanding Flags
* --verify: This flag instructs Forge to verify the contract on platforms like Etherscan, Sourcify, or Blockscout (for supported networks), ensuring that the contract source code is publicly visible and verified.

* Verbosity (-vvvv): This flag controls the level of detail in the logs and traces output:
  * -vv: Displays logs emitted during tests, including assertion errors (expected vs. actual values).
  * -vvv: Adds stack traces for failing tests.
  * -vvvv: Shows stack traces for all tests and setup traces for failing tests.
  * -vvvvv: Always displays full stack traces and setup traces.
