# <img src="logo.svg" alt="Monerium" width="400px">

![GitHub release](https://img.shields.io/github/release/monerium/smart-contracts.svg)

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


| Contract               | Mainnet																		  | Rinkeby 																	 | Ropsten                                    |
|------------------------|----------------------------------------------|--------------------------------------------|--------------------------------------------|
| ERC20Lib               |0xf38a10ee8b591e09208ff3d9b033abfbf5a6bf9c		| 0x218bb707be04ab12a28e339cd654b151a9a72d9e | 0xe28884ed5bd43e3f9f1dd733d254c9f5c6f983d2 |
| ERC677Lib              |0x071b13ab779fae6ac1d1beceeccaf7369a251036		| 0xc9d673d30b9598a70c63ebe72f0167fc80e431f0 | 0x95f066a44a8261ff91393664b0e8a19118e63ba3 |
| ISK                    |0x6e9e62eacad75e4b130db84f3bcba390dac47944		| 0xe6f9ad37afe22edc33c482d7694b90333d14498e | 0x7ba92741bf2a568abc6f1d3413c58c6e0244f8fd |
| Migrations             |0x496d5aa262f9f044769caf1a5303c89fb36adeef		| 0x8222eca943e85b08f509436d8cf6314bcb8a0bb4 | 0x39ad1ad871787ba4b3df5b8ac3d81b2c9b7c6290 |
| MintableTokenLib       |0x82d59b83b00475e009e913a6e470aea1e2dcc451		| 0xf09b796c0cd1a9569a0a2d92512c101bfb47fbb3 | 0xb46605f088fdd4547250351c84500f2925c89a85 |
| SafeMath               |0x2e7e62e0bea9f9e0d5957550d147bf1dd4580880		| 0x4031b16a22f650b132643dbe2481a7db3ce22340 | 0x9de2debd521aabdbc48ccd2acea45a7a6b995f55 |
| SmartController (ISK)  |0x54eb7ed5f98b7f498e3b59de9f2d3774394f42a7		| 0xd2d5f6ee4fb0182e1735bbda2e8103099d3b4aa1 | 0x6196d618d97d01645c1fd03a0748800da16efbf3 |
| SmartController (USD)  |0xf7958b010226ae8791debfee6df3f20f7a13b623		| 0xe2482f228a7098d9d58e5f70d4712d46e7ba7310 | 0x042b24bb81660cf6b3db649aa0596e69e5174a81 |
| SmartTokenLib          |0x3ea4e0542ab3220b3c514d041ecea51ca93baa9b		| 0xdada997f5c49cac5d458bc4e3caf28e741eac037 | 0x2d72003cccf633dfd1966df8c5c19129e30cd9fd |
| Storage (ISK)          |0xd86984389d3b02c46201eb1f1ec07a0f47b403fa		| 0x5881f17c4627cfee259a852ee96f8f23e641e6c5 | 0xd3bfe8fcf6926ecf33562667b7882ecc5a62b755 |
| Storage (USD)          |0xc9ba890b119ed6ebc7fdc1c0613c0d7f4d7307a6		| 0xe8d4741d06dbf08dd323c1f7972ceb09283674e8 | 0x57f1b40baf4d5708a15fea71e06841897cd2d262 |
| TokenStorageLib        |0xaa881be95479a669544d44de648562eca10b8762		| 0x855368e1c36415de1e9624dbf2d93c7efed4baa4 | 0x0121490da48b5fe099be3542176219a2a32ebabd |
| USD                    |0x7a83d84801fe56570e942f6fef6657f2ae3ebdd6		| 0xb63baffa7f19b1eeec270804b359b858a330bf20 | 0x3231cb76718cdef2155fc47b5286d82e6eda273f |

Current version is v1.0.0.

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
