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
| ERC20Lib               |0xf38a10ee8b591e09208ff3d9b033abfbf5a6bf9c		| 0xc5fe215f75a51026d26c82d9395fd2445773e9ef | 0xe28884ed5bd43e3f9f1dd733d254c9f5c6f983d2 |
| ERC677Lib              |0x071b13ab779fae6ac1d1beceeccaf7369a251036		| 0x4fa7901ce06da9ceb62245a1f8668e5e53955de9 | 0x95f066a44a8261ff91393664b0e8a19118e63ba3 |
| ISK                    |0x6e9e62eacad75e4b130db84f3bcba390dac47944		| 0x67b0b35e14702de6ad59fcd54a736af5a4d02786 | 0x7ba92741bf2a568abc6f1d3413c58c6e0244f8fd |
| Migrations             |0x496d5aa262f9f044769caf1a5303c89fb36adeef		| 0x8fbf69c5cfd9d7c22fbd4cac527368c89f7463b1 | 0x39ad1ad871787ba4b3df5b8ac3d81b2c9b7c6290 |
| MintableTokenLib       |0x82d59b83b00475e009e913a6e470aea1e2dcc451		| 0xd612b0298bc1559c925a037898f984ed0de7c679 | 0xb46605f088fdd4547250351c84500f2925c89a85 |
| SafeMath               |0x2e7e62e0bea9f9e0d5957550d147bf1dd4580880		| 0xf0f0147ecdc7d97d13a035ae61b57ac3c7032099 | 0x9de2debd521aabdbc48ccd2acea45a7a6b995f55 |
| SmartController (ISK)  |0x54eb7ed5f98b7f498e3b59de9f2d3774394f42a7		| 0x892b247bfb55e7b3687a8fc5439ccd3b5bed5493 | 0x6196d618d97d01645c1fd03a0748800da16efbf3 |
| SmartController (USD)  |0xf7958b010226ae8791debfee6df3f20f7a13b623		| 0xc6be039602ca7ef785225340cf271247e300abaf | 0x042b24bb81660cf6b3db649aa0596e69e5174a81 |
| SmartTokenLib          |0x3ea4e0542ab3220b3c514d041ecea51ca93baa9b		| 0xc40fa2522cd0ac1634c3341d7e64683d0c0150d9 | 0x2d72003cccf633dfd1966df8c5c19129e30cd9fd |
| Storage (ISK)          |0xd86984389d3b02c46201eb1f1ec07a0f47b403fa		| 0x48b2b9955d6935dcba488ed51c4e63ad799f096b | 0xd3bfe8fcf6926ecf33562667b7882ecc5a62b755 |
| Storage (USD)          |0xc9ba890b119ed6ebc7fdc1c0613c0d7f4d7307a6		| 0xf1ae3eb708d8263c8b817e2dabe8f9fc0654991b | 0x57f1b40baf4d5708a15fea71e06841897cd2d262 |
| TokenStorageLib        |0xaa881be95479a669544d44de648562eca10b8762		| 0xd1188031e60c72c48379c7fc0aa609e0bdcd1362 | 0x0121490da48b5fe099be3542176219a2a32ebabd |
| USD                    |0x7a83d84801fe56570e942f6fef6657f2ae3ebdd6		| 0xe82f47e10979db5a9a9497c84477a0e94d1bc742 | 0x3231cb76718cdef2155fc47b5286d82e6eda273f |

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
