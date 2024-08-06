# Migrating from Contract v1 to v2

In the evolution of our smart contract environment, we embark on deploying a more stable and robust version 2 (`V2`). However, the path to directly transfer user balances from the original contract (`V1`) to the new version presents complexities. 

This document outlines a plan to migrate funds safely from `V1` to `V2`, ensuring the `V1` token frontend's address remains operational as a legacy interface. 

We aim to facilitate a seamless transition, maintaining continuity for our users while leveraging the enhancements of `V2`.

## Requirements

Before starting the migration process, we make sure that the following requirements are met:

- [ ] The SmartController is upgraded to version **1.2.2**, incorporating the `pausable` feature.
- [ ] Possession of the `TokenFrontend` address.
- [ ] Access to the **version 2 (`V2`) foundry repository**, including all dependencies.

## Versions

| Contract                 | Version  |
| ------------------------ | -------- |
| Node.js                  | v18.17.0 |
| Forge                    | v0.2.0   |
| Monerium ControllerToken | v2.0.0   |
| Monerium TokenFrontend   | v1.0.0   |
| Monerium SmartController | v1.2.2   |

## Architectural Overview
*Legacy V1 architecture VS the new V2 architecture*

![Pasted image 20240329134835](https://github.com/monerium/smart-contracts/assets/17710875/42f6b845-28c0-44aa-8be0-cd9b63a8535f)

*V2 architecture with retro compatibility with the legacy V1 frontend*
![Screenshot 2024-03-29 at 13 49 49](https://github.com/monerium/smart-contracts/assets/17710875/51e96b4d-014d-4f11-9a2e-262f85fcbd3b)


The objective is to migrate the assets currently held within `TokenStorage` to the storage system of the `Proxy`.

By adopting proxy storage, we introduce adaptability to our contract architecture, enabling the management of stored funds to evolve alongside technological advancements and users' needs. 

Moreover, with its standard `ERC20` capabilities, the existing `Frontend` interface will maintain its functionality. User interactions with the `Frontend` will be seamlessly redirected to the `Proxy`, which will communicate with the `Implementation` contract.

This strategy allows us to present our partners and users with a modernized entry point to our currency, featuring updated functionalities while still offering the familiar services and addresses they have come to rely on.

## Step-by-Step Migration Guide

The migration process involves a `JavaScript` script that creates a `Foundry` Solidity script, utilizing a list of users acquired from compiling logs.

After completion, we will use one `wallet` to deploy and run the migration and set the final `roles` and `owners`.

> This documentation focuses on the migration of a single token. It is recommended to deploy all four tokens simultaneously with the same implementation contract and then conduct each migration separately

### 1. Deploying the `V2` contract.

To initiate the deployment of the V2 contract, follow these steps within the V2 foundry repository:

1. Set the following environment variables in your terminal:

```sh
export PRIVATE_KEY=<your_key>
export RPC_URL=<your_provider>
export ETHERSCAN_API_KEY=<your_api_key>
```
> Note: When deploying to Polygon or Gnosis chain, place your `PolygonScan` or `GnosisScan` API key in the `ETHERSCAN_API_KEY` field. For deployments to other chains, additional details can be found in `script/deployAll.sh`

2. To deploy, execute the following command:
```sh
forge script script/deploy.s.sol:ControllerEUR --rpc-url $RPC_URL --broadcast --etherscan-api-key $ETHERSCAN_API_KEY --verify $VERIFIER_URL
```

Your V2 `Proxy` and `Implementation` contracts are now deployed and verified on the blockchain explorer.

### 2. Configuring the `V2` contract.

Provide `admin` and `system` roles to the `wallet` used for the migration (the same one used for deployment). These roles are crucial early in the fund migration process to set `MintAllowance`.

1. Set the following environment variables in your terminal:
```sh
 export TOKEN_ADDRESS=<proxy_address>
 export SYSTEM_ADDRESS=<your_wallet_address>
 export ADMIN_ADDRESS=<your_wallet_address>
```

2. To launch, execute the following command: 
```sh
forge script script/setAdminAndSystem.s.sol --rpc-url $RPC_URL --broadcast
```

Your `V2` contract is now ready to launch the Migration script. 

### 3. Pause the `V1` token

During the migration, we will fetch a list of holders from `Etherscan`. To ensure this list remains unchanged, it's crucial to **pause** all operations such as `transfer`, `mint`, and `burn` on the `V1` token. This action will freeze the state of the token, securing the integrity of holder balances throughout the transition process to `V2`.

### 4. Generate the migration script

A JavaScript script crafts a Solidity script by using `V1` and `V2` token addresses.

The script compiles a list of `V1` token holders from `Transfer` logs, then creates a mapping of holders to their balances using `V1`'s `balanceOf` call.

> Note: Holders with a `balanceOf` 0 are excluded from the migration.

The generated Solidity script then sets `V2`'s mint allowance to equal `V1`'s `totalSupply`.

For each holder, it mints their `V1` balance into the new `V2` token.

The process concludes with `totalSupply` check between `V2` and `V1`. 

1. To create the migration script, execute the following command:
```sh
node script/generateBatchMint.js <RPC> <v2-address> <startBlock> <v1-address>
```
> Note:  the generated script will be located in the `script` directory, named `BatchMint-{v1-address}.s.sol`.

2. Begin the migration by running:
```sh
forge script script/BatchMint-{v1-address}.s.sol  --rpc-url $RPC_URL --broadcast
```
3. The funds have been successfully migrated to the `V2` contract.

> Note: It's crucial to understand that the funds in `V1` remain unchanged. Instead, the migration process duplicates the balances into the `V2` contract. 
> The `V1` contract will be discontinued in favor of `V2`, hence the state of `V1` is preserved and not altered during this transition.

### 5. Redirecting `V1` `TokenFrontend` Calls to `V2` `Proxy`

With the funds successfully migrated to the `V2` contract, the next step involves setting up `V2`'s configurations—specifically, its roles and ownership. Additionally, we need to establish a connection between `V1`'s `TokenFrontend` and `V2`'s `Proxy`.

1. Remove the migration's `wallet` as `admin` and `system` 
```sh
 export TOKEN_ADDRESS=<proxy_address>
 export WALLET_ADDRESS=<your_wallet_address>
 forge script script/unsetAdminAndSystem.s.sol --rpc-url $RPC_URL --broadcast
```
2. Configure the `V2` token with `admins`, `system` and `maxMintAllowance`
```sh
export TOKEN_ADDRESS=<proxy_address>
export SYSTEM_ADDRESS=<system_address>
export ADMIN_ADDRESS=<admin_address>
export MAX_MINT_ALLOWANCE=<amount_in_wei>
forge script script/configureToken.s.sol --rpc-url $RPC_URL --broadcast
 ```
3. Transfer ownership of the `V1` token and `Controller` to the dev key
  
5. Configure the `V2` token with a minting allowance

 Use the `admin safe` to set the mint allowance. 

5. Connect the `V2` proxy as `controller` for the `V1` `TokenFrontend`
```sh
export TOKEN_ADDRESS=<v2_proxy_address>
export FRONTEND_ADDRESS=<v1_frontend_address>
export OWNER_ADDRESS=<final_owner_address>
forge script script/connectV2toV1.s.sol --rpc-url $RPC_URL --broadcast
```

> This marks the completion of our migration process. Henceforth, the `TokenFrontend` will direct its calls to the `V2` `Proxy`, ensuring that user funds, now migrated, are managed through the updated contract.

