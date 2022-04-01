# <img src="docs/logo.svg" alt="Monerium" width="400px">

![GitHub](https://img.shields.io/github/license/monerium/smart-contracts.svg)
![GitHub release](https://img.shields.io/github/release/monerium/smart-contracts.svg)
[![Build Status](https://github.com/monerium/smart-contracts-private/actions/workflows/tests.yml/badge.svg)](https://github.com/monerium/smart-contracts-private/actions/workflows/tests.yml)

The [Monerium](https://monerium.com) e-money platform offers programmable fiat money on blockchains, an indispensable building block for the nascent blockchain economy.

## Tokens
### Ethereum
| EUR | GBP | ISK | USD |
| :----: | :----: | :----: | :----: |
| <small><a href="https://etherscan.io/token/0x3231cb76718cdef2155fc47b5286d82e6eda273f">![EUR](docs/qr-eth-eur.png)</a><br /><a href="https://app.ens.domains/name/eur.monerium.eth">eur.monerium.eth</a></small> | <small><a href="https://etherscan.io/token/0x7ba92741bf2a568abc6f1d3413c58c6e0244f8fd">![GBP](docs/qr-eth-gbp.png)</a><br /><a href="https://app.ens.domains/name/gbp.monerium.eth">gbp.monerium.eth</a> | <small><a href="https://etherscan.io/token/0xc642549743a93674cf38d6431f75d6443f88e3e2">![ISK address](docs/qr-eth-isk.png)</a><br /><a href="https://app.ens.domains/name/isk.monerium.eth">isk.monerium.eth</a></small> | <small><a href="https://etherscan.io/token/0xbc5142e0cc5eb16b47c63b0f033d4c2480853a52">![USD address](docs/qr-eth-usd.png)</a><br /><a href="https://app.ens.domains/name/usd.monerium.eth">usd.monerium.eth</a></small> |
### Polygon Pos
| EUR | GBP | ISK | USD |
| :----: | :----: | :----: | :----: |
| <small><a href="https://polygonscan.com/token/0x18ec0A6E18E5bc3784fDd3a3634b31245ab704F6">![EUR](docs/QR-POLY-EUR.png)</a><br /><a href="https://polygonscan.com/token/0x18ec0A6E18E5bc3784fDd3a3634b31245ab704F6">Polygon.Pos.EUR</a></small> | <small><a href="https://polygonscan.com/token/0x75792CBDb361d80ba89271a079EfeE62c29FA324">![GBP](docs/QR-POLY-GBP.png)</a><br /><a href="https://polygonscan.com/token/0x75792CBDb361d80ba89271a079EfeE62c29FA324">Polygon.Pos.GBP</a> | <small><a href="https://polygonscan.com/token/0xf1bBf27A9D659D326efBfa5D284EBaeFB803983D">![ISK address](docs/QR-POLY-ISK.png)</a><br /><a href="https://polygonscan.com/token/0xf1bBf27A9D659D326efBfa5D284EBaeFB803983D">Polygon.Pos.ISK</a></small> | <small><a href="https://polygonscan.com/token/0x64E97c1a6535afD4a313eF46F88A64a34250B719">![USD address](docs/QR-POLY-USD.png)</a><br /><a href="https://polygonscan.com/token/0x64E97c1a6535afD4a313eF46F88A64a34250B719">Polygon.Pos.USD</a></small> |


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

| Contract | Mainnet ([v1.0.3](https://github.com/monerium/smart-contracts/releases/tag/v1.0.3)) | Polygon-Pos ([v1.10.0](https://github.com/monerium/smart-contracts/releases/tag/v1.10.0)) | Ropsten ([v1.0.3](https://github.com/monerium/smart-contracts/releases/tag/v1.0.3)) | Kovan ([v1.0.3](https://github.com/monerium/smart-contracts/releases/tag/v1.0.3)) | Rinkeby ([v1.0.3](https://github.com/monerium/smart-contracts/releases/tag/v1.0.3)) |
| --- | --- | --- | --- | --- | --- |
| EUR      | 0x3231cb76718cdef2155fc47b5286d82e6eda273f | 0x18ec0A6E18E5bc3784fDd3a3634b31245ab704F6  | 0x0ae91c2b9e31e92871129117d908b0963c054048        | 0x9b8fd8fcfaa2438d11e7ed77d5afb6c2e1044b37 | 0x25c13fc529dc4afe4d488bd1f2ee5e1ec4918e0b |
| GBP      | 0x7ba92741bf2a568abc6f1d3413c58c6e0244f8fd | 0x75792CBDb361d80ba89271a079EfeE62c29FA324  | 0xd9979346224e7b147caddf399b56357e20d3e67c        | 0xe28884ed5bd43e3f9f1dd733d254c9f5c6f983d2 | 0x01df10e345d0364d3a5b8422a66af6305803bd1e |
| ISK      | 0xc642549743a93674cf38d6431f75d6443f88e3e2 | 0xf1bBf27A9D659D326efBfa5D284EBaeFB803983D  | 0x80b02ef56cbbc542f0ce89ad1d2a680244da9a63        | 0x39ad1ad871787ba4b3df5b8ac3d81b2c9b7c6290 | 0x0c9d7a0d8bf4bc9d15f577bbf650ebc8044a71db |
| USD      | 0xbc5142e0cc5eb16b47c63b0f033d4c2480853a52 | 0x64E97c1a6535afD4a313eF46F88A64a34250B719  | 0x3781dcdd60e006e33b664dce0d6be934f0a139c8        | 0x57724f65b3f914de7820c6f76b2099fa3a90f509 | 0x09c0a236e1227500f495cb0731c4af69b49639a5 |

The token addresses can be resolved using ENS in compatible wallets.

| Contract | Mainnet                                                               | Rinkeby       |
| -------- | --------------------------------------------------------------------- | ------------- |
| EUR      | [eur.monerium.eth](https://manager.ens.domains/name/eur.monerium.eth) |               |
| GBP      | [gbp.monerium.eth](https://manager.ens.domains/name/gbp.monerium.eth) |               |
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
