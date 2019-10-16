# <img src="docs/logo.svg" alt="Monerium" width="400px">

![GitHub](https://img.shields.io/github/license/monerium/smart-contracts.svg)
![GitHub release](https://img.shields.io/github/release/monerium/smart-contracts.svg)
[![Build Status](https://travis-ci.com/monerium/smart-contracts.svg)](https://travis-ci.com/monerium/smart-contracts)

The [Monerium](https://monerium.com) e-money platform offers programmable fiat money on blockchains, an indispensable building block for the nascent blockchain economy.

## Tokens

|                                                                                                                                                  USD                                                                                                                                                   |                                                                                                                                                  ISK                                                                                                                                                   |
| :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| <small><a href="https://etherscan.io/token/0xbc5142e0cc5eb16b47c63b0f033d4c2480853a52">![USD address](docs/0xbc5142e0cc5eb16b47c63b0f033d4c2480853a52.png)0xbc5142e0cc5eb16b47c63b0f033d4c2480853a52</a><br /><a href="https://manager.ens.domains/name/usd.monerium.eth">usd.monerium.eth</a></small> | <small><a href="https://etherscan.io/token/0xc642549743a93674cf38d6431f75d6443f88e3e2">![ISK address](docs/0xc642549743a93674cf38d6431f75d6443f88e3e2.png)0xc642549743a93674cf38d6431f75d6443f88e3e2</a><br /><a href="https://manager.ens.domains/name/isk.monerium.eth">isk.monerium.eth</a></small> |

## Token Design

Four cooperating Ethereum smart-contracts are deployed for each e-money currency token that is [ERC20](https://github.com/ethereum/EIPs/issues/20) compliant.

* **Token Frontend**: This contract implements the [ERC20](https://github.com/ethereum/EIPs/issues/20) token standard and provides a permanent Ethereum address for the token system. The contract only exposes the required ERC20 functionality to the user and delegates all of the execution to the controller.
* **Controller**: The controller is responsible for the business logic. The controllers are further separated by the functionality they provide into; StandardController, MintableController and SmartController.
* **Token Storage**: Storage of e-money token ledger.
* **Validator**: The validator can be used by the controllers to approve and validate transactions before they are made.

![token system design](docs/contracts.jpg)

Using this design we're able to upgrade the business logic, to fix bugs or add functionality, while providing a fixed address on the blockchain and permanent access to the token bookkeeping.

### Implementation

The token system is implemented using Solidity, the most widely used high level language targeting the EVM. We build upon community vetted libraries where possible to minimize the risk of bugs.

Additional functionality has been implemented in `MintableTokenLib.sol` and `SmartTokenLib.sol`. This includes minting and burning tokens and defining validators who determine whether token transactions are valid or not.

Functionality which requires authorization is protected by OpenZeppelin's implementation of the Ownable contract. The management of the private key of the owner is very simple at the moment but for v1.0.0 a multi-signature account or a simple DAO will be used.

### Solidity libraries

Libraries in Solidity provide the means to deploy an implementation once as a compiled byte code but without an execution context (storage). Contracts deployed subsequently can then be statically linked to the library.

Our token system takes advantage of this feature to save gas deploying multiple tokens. It can also be argued that sharing audited libraries between contracts can reduce the risk of bugs and worst case ease the replacement of a buggy implementation.

## Building

1. Clone the repository

    ```sh
    git clone --recursive https://github.com/monerium/smart-contracts.git
    cd smart-contracts
    ```

2. Install dependencies

    ```sh
    yarn install
    ```

3. Run truffle

    ```sh
    npx truffle develop
    ```

4. Compile token system

    ```sh
    truffle(develop)> compile --all
    ```

5. Deploy

    ```sh
    truffle(develop)> migrate --reset
    ```

6. Run test suite

    ```sh
    truffle(develop)> test
    ```

## Development

To ease the development, deployment and interaction with the token system we're using truffle.

Truffle's ganache simulates full client behavior and makes developing Ethereum applications much faster while Truffle is a development environment, testing framework and asset pipeline for Ethereum.

Development happens on the master branch and we use [Semantic Versioning](http://semver.org) for our tags. The first pre-release version deployed on a non-testrpc blockchain is v0.7.0.

## Deployment

```sh
# npx truffle migrate [--network <name>]
```

| Contract              | Mainnet ([v1.0.3](https://github.com/monerium/smart-contracts/releases/tag/v1.0.3)) | Rinkeby ([v1.0.3](https://github.com/monerium/smart-contracts/releases/tag/v1.0.3)) | Ropsten ([v1.0.3](https://github.com/monerium/smart-contracts/releases/tag/v1.0.3)) |
| --------------------- | ----------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| **EUR**               |                                                                                     | 0x25c13fc529dc4afe4d488bd1f2ee5e1ec4918e0b                                          | 0x0ae91c2b9e31e92871129117d908b0963c054048                                          |
| **GBP**               |                                                                                     | 0x01df10e345d0364d3a5b8422a66af6305803bd1e                                          | 0xd9979346224e7b147caddf399b56357e20d3e67c                                          |
| **ISK**               | 0xc642549743a93674cf38d6431f75d6443f88e3e2                                          | 0x0c9d7a0d8bf4bc9d15f577bbf650ebc8044a71db                                          | 0x80b02ef56cbbc542f0ce89ad1d2a680244da9a63                                          |
| **USD**               | 0xbc5142e0cc5eb16b47c63b0f033d4c2480853a52                                          | 0x09c0a236e1227500f495cb0731c4af69b49639a5                                          | 0x3781dcdd60e006e33b664dce0d6be934f0a139c8                                          |
| BlacklistValidator    | 0x774681a648125d46f35017cf6cec43a41857254e                                          | 0x71db9342ab4fe41bb1f3f74f944cbebb2719f138                                          | 0xf83482dd764551e464bb4f621a3599bfe763d69a                                          |
| ERC20Lib              | 0x57724f65b3f914de7820c6f76b2099fa3a90f509                                          | 0xcfcc3ce5b2a8794d067497cd0c69219b182f959b                                          | 0x5f45aa0b2fafa8b6ddb98ad0e9f4e4d8a6157d5a                                          |
| ERC677Lib             | 0x0d43c529aab2a3c1bca65827eb5136c3276f0820                                          | 0x2d4131724cdcc99806c1cba41f1974681a379cd7                                          | 0x77a7dd0ee4f3e424163dce5f67072baf11eafc3c                                          |
| Migrations            | 0x1faa6f84d5cf021a9c3d12d05fad2c31645f02cc                                          | 0x6215a2a0bfea76bb60bbd8115c8330a8c0f22620                                          | 0xd4aea361eb988a260d3c272a6c355528714b99da                                          |
| MintableTokenLib      | 0x3fd2c5067da1f41cf16d8a0230efacbb7369d53f                                          | 0xbe78ec9ae729f89b526d86b1628b8d3f90e9ba84                                          | 0x6afd70e54a3644197e76be4d57e23f5841f7344c                                          |
| SafeMath              | 0x6c91954e794f17ae65a3b9a9102c1d39b3b9e6be                                          | 0x91e8a58d073dcd2433a5f99f35fa20d7fc7dc5bb                                          | 0xef38de31fbd8ae845ca48a3372150eb6dec715e9                                          |
| SmartController (EUR) |                                                                                     | 0xa53ad1abf2eaf3fd6489183151a905eeeccb4063                                          | 0x11a9c75f1a6af4d48e5e47e78a3f09c5fe45c5a0                                          |
| SmartController (GBP) |                                                                                     | 0xaf1f2b0f0eacbd92c55cae2892e56230731b8ec4                                          | 0x0b47844f8c71736126ec31f8be573f462b2faa24                                          |
| SmartController (ISK) | 0x9b8fd8fcfaa2438d11e7ed77d5afb6c2e1044b37                                          | 0xc1aab70bc27987f3941192e78684e125a677f3df                                          | 0x098cad026024f323cf379c994550bc3fbd246a01                                          |
| SmartController (USD) | 0x6015bf147bcc9ae8515df6c571e58a4fa8afbf89                                          | 0x45139e04aff96e722879d49a32a9655b02c449e2                                          | 0xc6af8a2a969bcd086a505ed1995179605bcbc930                                          |
| SmartTokenLib         | 0x7f0a5bf88eb3921b170048ecea528bd7cc6df70e                                          | 0x1531d4e573ec48f1fa61ed74b5a5594f5c39e8ed                                          | 0xc2e2547e7848fcb5fd7f98bd3ac9e3bba97b238a                                          |
| storage (isk)         | 0x060bf08d6da61c2107178b10549fedb7fb5f58bd                                          | 0x4e3244ff304ee4ec33b5c06cfa793aa8de8e2efe                                          | 0xd621914541dc08be2fa6dd46dcbac62b031b25d9                                          |
| storage (usd)         | 0xc3c6e46b8d6d1b2716a890a2e949a9facf2f76ec                                          | 0xc67ad12d1af21b94b6d9ab602e4c05df2f78286f                                          | 0x710b7d8bba9c1b3d121f884f8da5933c33adb118                                          |
| TokenStorageLib       | 0x13e6574730e4ae1b425967db30e9d5dd5bcdde06                                          | 0xdba76f85c41b69c90c4c6335d37237b69b2d396f                                          | 0x8432d58ec5c6c16679de298db186b988d1130353                                          |

The token addresses can be resolved using ENS in compatible wallets.

| Contract | Mainnet                                                               | Rinkeby       |
| -------- | --------------------------------------------------------------------- | ------------- |
| ISK      | [isk.monerium.eth](https://manager.ens.domains/name/isk.monerium.eth) | monerium.test |
| USD      | [usd.monerium.eth](https://manager.ens.domains/name/usd.monerium.eth) |               |

## Unit tests

The token system ships with JavaScript unit tests.

```sh
# make test
```

## Code coverage

Code coverage for the token system can be checked with [solidity-coverage](https://github.com/sc-forks/solidity-coverage).

```sh
# make coverage
```

![Code coverage](docs/code-coverage.png)

## License

```text
Copyright 2019 Monerium ehf.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
