# <img src="docs/logo.svg" alt="Monerium" width="400px">

![GitHub](https://img.shields.io/github/license/monerium/smart-contracts.svg)
![GitHub release](https://img.shields.io/github/release/monerium/smart-contracts.svg)

The [Monerium](https://monerium.com) e-money platform offers programmable fiat money on blockchains, an indispensable building block for the nascent blockchain economy.

## Tokens

| USD                                                                                                                                                                                                                                        | ISK                                                                                                                                                                                                                                        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| <center>![USD address](/docs/0x7a83d84801fe56570e942f6fef6657f2ae3ebdd6.png)</center><center><small>[0x7a83d84801fe56570e942f6fef6657f2ae3ebdd6](https://etherscan.io/address/0x7a83d84801fe56570e942f6fef6657f2ae3ebdd6)</small></center> | <center>![ISK address](/docs/0x6e9e62eacad75e4b130db84f3bcba390dac47944.png)</center><center><small>[0x6e9e62eacad75e4b130db84f3bcba390dac47944](https://etherscan.io/address/0x6e9e62eacad75e4b130db84f3bcba390dac47944)</small></center> |

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

The deployment cycle for beta versions (up to v1.0.0) is as follows. During development the smart contracts are continuously deployed and tested locally on testrpc. A patch version update is deployed on the Monerium testnet, a federated blockchain, run by Monerium. A minor version update is deployed on the Rinkeby testnet.


| Contract              | Mainnet ([v1.0.0](https://github.com/monerium/smart-contracts/releases/tag/v1.0.0)) | Rinkeby ([v1.0.1](https://github.com/monerium/smart-contracts/releases/tag/v1.0.1)) | Ropsten ([v1.0.1](https://github.com/monerium/smart-contracts/releases/tag/v1.0.1)) |
| --------------------- | ----------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| BlacklistValidator    | 0x35f72854df481662365494b5241e0376937e16a5                                          | 0x10ec39f8870b34ff818e15017fd0758291ea4c38                                          | 0x512c7ac91e79abece117e19b78d200bbf8dc5ecc                                          |
| ERC20Lib              | 0xf38a10ee8b591e09208ff3d9b033abfbf5a6bf9c                                          | 0x127153a40aac811ca169744ab6156222c2667545                                          | 0x912316ca3af0fa83737d7342b4842553571c9cac                                          |
| ERC677Lib             | 0x071b13ab779fae6ac1d1beceeccaf7369a251036                                          | 0x5b9d0cd7c015d5ccaba3ababb390a431ebeb74e1                                          | 0x4f396a4a92d38110704a29dbc33ab818724c17e1                                          |
| ISK                   | 0x6e9e62eacad75e4b130db84f3bcba390dac47944                                          | 0xdd6539ac2b758e15b1c40290a5c3a9984d21ee3c                                          | 0xe1d416a18e668a0be12d501391bab7105383b38b                                          |
| Migrations            | 0x496d5aa262f9f044769caf1a5303c89fb36adeef                                          | 0xf777c8ba93831dc04b43ea87f5f33b7cacc9f7d1                                          | 0x5b9874f68da7c1421704c103965cd92598311ab3                                          |
| MintableTokenLib      | 0x82d59b83b00475e009e913a6e470aea1e2dcc451                                          | 0x71690fcb58f7e2e92ef0b3b553dc1d112501a1fd                                          | 0x36b9950d1af690a3685e0e5ba05076b6fd04512e                                          |
| SafeMath              | 0x2e7e62e0bea9f9e0d5957550d147bf1dd4580880                                          | 0xa724ac98d0069f618387e1a9287b6e016579a6e1                                          | 0x2e99f38da8e163598ddd2d9860e09e6fdd2ba67a                                          |
| SmartController (ISK) | 0x54eb7ed5f98b7f498e3b59de9f2d3774394f42a7                                          | 0x8573a0ac20be38bcb904b81f5ac0156ade4326b0                                          | 0x85c80683e06bdc53339383e91b26f40692a911cf                                          |
| SmartController (USD) | 0xf7958b010226ae8791debfee6df3f20f7a13b623                                          | 0x775c7f7e44539cabf4ed5f42804aa422265a87ad                                          | 0x5613fd988a46483d8f0dd81145aebc6151f6ff1b                                          |
| SmartTokenLib         | 0x3ea4e0542ab3220b3c514d041ecea51ca93baa9b                                          | 0x0df88f7b7ec88615be8b15496fe16fbbc1aef20a                                          | 0x0b3d87c1c3cad6a8ce744ba18cb0ae52062ed633                                          |
| Storage (ISK)         | 0xd86984389d3b02c46201eb1f1ec07a0f47b403fa                                          | 0xaa25e41dfd515c20c871fcee3b57ebc2da207ec4                                          | 0x0407e7de6e1fcedcca99b8c8953f972bd33014d1                                          |
| Storage (USD)         | 0xc9ba890b119ed6ebc7fdc1c0613c0d7f4d7307a6                                          | 0x8523e538cd91fc5c61594166c542f9733f845cbe                                          | 0x3ce2d1395d2dea91144cc93533f9cf4685231201                                          |
| TokenStorageLib       | 0xaa881be95479a669544d44de648562eca10b8762                                          | 0x66ac5d0b61a3177bd9229a7b88cfef2eeb66a84c                                          | 0x125159102bf292f6abbb95ccfc29c01e275e2871                                          |
| USD                   | 0x7a83d84801fe56570e942f6fef6657f2ae3ebdd6                                          | 0xe8daa78c4570d78f2d8a7dd823b391eca2dfd96c                                          | 0xb3dce07230165a13b5b0aeee2ed62834887800c7                                          |

## Unit tests

The token system ships with JavaScript unit tests.

```sh
# make test
```

![Unit tests](docs/test-suite.png)

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