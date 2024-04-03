# Monerium's emoney Smart Contracts
![GitHub](https://img.shields.io/github/license/monerium/smart-contracts.svg)
[![release](https://img.shields.io/github/v/tag/monerium/smart-contracts?label=version)](https://github.com/monerium/smart-contracts/releases)

This repository features Monerium's emoney 'stablecoin' smart contracts deployed on EVM-compatible blockchains.

The [Monerium](https://monerium.com) e-money offers programmable fiat money on blockchains, an indispensable building block for the nascent blockchain economy.

Monerium EMI is an Electronic Money Institution, currently the only financial entity licenced to issue e-money on blockchains. Electronic money (e-money) has been recognized in the European Economic Area (EEA) as a digital alternative to cash since 2000 when the first e-money Directive was introduced. Monerium e-money is 1:1 backed in fully segregated, unencumbered, high-quality liquid assets and unconditionally redeemable on demand. [Read more about e-money here](https://monerium.com/monerium/2019/06/28/e-money-the-digital-alternative-to-cash.html).

## Table of Contents

- [Architecture](#architecture)
- [Deployment](#deployment)
- [Token Features](#token-features)
  - [ERC20](#erc20)
  - [Access and Ownable](#access-and-ownable)
  - [Upgradeable](#upgradeable)
  - [Blacklist](#blacklist)
  - [Minting and Burning](#minting-and-burning)
- [Additional Documentations](#additional-documentations)
  
## Architecture 

The token architecture employs OpenZeppelin's [UUPS Proxy Pattern](https://docs.openzeppelin.com/contracts/4.x/api/proxy#UUPSUpgradeable) for Upgradability. Each deployment environment  features a distinct instance of the implementation contract( [Token.sol](./src/Token.sol) ) alongside four proxy contracts ( [ERC1967Proxy.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.5/contracts/proxy/ERC1967/ERC1967Proxy.sol) ), corresponding to each e-money token Monerium introduces, delegating function calls to the implementation contract while using their respective storage.

Additionally, all four tokens also hold access to a shared Blacklist validator ( [BlacklistValidatorUpgradeable.sol](./src/BlacklistValidatorUpgradeable.sol) ). 

![Screenshot 2024-04-03 at 12 48 12](https://github.com/monerium/smart-contracts/assets/17710875/326177b6-0754-47c7-8098-4a420421bded)

## Deployment

For detailed setup, deployment, and testing instructions, visit [this dedicated page](./docs/deployment.md).

## Token Features

We at Monerium are excited to talk to all developers and builders who want to use money in their applications.
Go to [monerium.com](https://monerium.com) and fill out the "Partner with Monerium" form and our expert staff
will be available to help you every step of the way, from implementation to ongoing operations.

### ERC20 

The implementation contract of the token employs OpenZeppelin's [ERC20PermitUpgradeable](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/token/ERC20/extensions/ERC20PermitUpgradeable.sol) for standard ERC20 operations.

### Access and Ownable

The implementation contract of the token utilizes OpenZeppelin's [Ownable2StepUpgradeable](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/access/Ownable2StepUpgradeable.sol) and [AccessControlUpgradeable](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/access/AccessControlUpgradeable.sol) for role-based permissions and ownership management.

A designated `owner` holds the authority for essential contract management tasks, including assigning admin and system roles and initiating upgrades to the implementation. The `admin` role is responsible for managing Mint Allowance, while the `system` role is tasked with executing Mint and Burn operations.

### Upgradeable

An updated implementation contract may be deployed, and the proxy contract will then delegate calls to this new version. The upgrade logic, inherent to the UUPS pattern, resides in the implementation contract and is strictly accessible by the `owner`'s address.

### Blacklist

The token's administrators can blacklist certain addresses which will prevent those from transferring or receiving tokens. This blacklist is shared between all four tokens of an environment. 

### Minting and Burning

Tokens can be minted or burned on demand. The contract supports having multiple minters under the `system` role.
The `admin` addresses will control how much each `system` is allowed to mint. The mint allowance mirrors the ERC20 allowances - as each `system` mints new tokens their allowance decreases. When it gets too low they will need the allowance increased again by one `admin` address. 

The `admin` address corresponds to a Gnosis MultiSig wallet, operated by Monerium's administrative personnel. They perform daily evaluations and adjustments to the mint allowance.

## Additional Documentations

  * [Token Design](./docs/tokendesign.md)
  * [Permit [ERC-2612]](./docs/permit.md)
  * [Migrating from `V1` to `V2`](./docs/migrating_V1_to_V2.md)

