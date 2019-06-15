# <img src="logo.svg" alt="Monerium" width="400px">

The [Monerium](https://monerium.com) e-money platform offers programmable fiat money on blockchains, an indispensable building block for the nascent blockchain economy.

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


| Contract               | Rinkeby																		|
|------------------------|--------------------------------------------|
| ERC20Lib               | 0xe7b1f1c4a99b68a3f84aeacb2de8ff86acfbf8a3 |
| ERC677Lib              | 0x29218e4c2d78e016ccaab256dbc9c3861bef389e |
| ISK                    | 0xcd8704bdb144f05c3c01d21943167b46684fe5c4 |
| Migrations             | 0x92227e4b662e02a84acea457711f1a24821fdede |
| MintableTokenLib       | 0x159b85aae18653162ba1ca4fb294ab1da3a3536e |
| SafeMath               | 0x0dd2411ad961ab71cf0583dd8f938193ec21dd19 |
| SmartController (ISK)  | 0xf2330aff917446c486e2d9b6014e9d9a6fbb2af4 |
| SmartController (USD)  | 0xadca2746f59e849abe656f337271dea4ddc5f33b |
| SmartTokenLib          | 0x5a9f218539142f2ddceb326be1f940b8c858ce02 |
| Storage (ISK)          | 0xe84501ce6c17d9104d1c3e607945b44cf656b941 |
| Storage (USD)          | 0x37fe072f85c878bd685b332fe9155f987a78bd96 |
| TokenStorageLib        | 0x3607493828521fa8edd3dd4d6a19fed10c5cb7af |
| USD                    | 0x8e4727c509e41cefa2ef6298c1b399049f4f8fe5 |

Current version is v0.9.7.

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

Copyright &copy; 2019, Gísli Kristjánsson for Monerium ehf.
