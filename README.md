# (Smart) Fiat Tokens

ERC20 is a suggested specification for Ethereum tokens. Once approved as an Ethereum Improvement Proposal (EIP), it will become a part of the standards for the Ethereum platform.

Smart contracts adhering to the specification have a common interface to token-related functionality and events.

![Our token system design](docs/token-design.png)

*Contracts are represented by grey boxes and libraries by blue boxes with rounded corners*


## Building

1. Clone the repository
	```sh
	$ git clone --recursive https://github.com/monerium/smart-contracts.git
	$ cd smart-contracts
	```

2. Install dependencies

	```sh
	$ npm install -g ethereumjs-testrpc
	$ npm install -g truffle
	```

3. Run testrpc

	`$ testrpc`

4. Compile token system

	`$ make compile`

5. Deploy

	`$ make migrate`

6. Run test suite

	`$ make test`


## Implementation

The token system is implemented using Solidity, the most widely used high level language targeting the EVM. We build upon community vetted libraries where possible to minimise the risk of bugs.

Additional functionality has been implemented in `MintableTokenLib.sol` and `SmartTokenLib.sol`. This includes minting and burning tokens and defining validators who determine whether token transactions are valid or not.

Functionality which requires authorization is protected by OpenZeppelin's implementation of the Ownable contract. The management of the private key of the owner is very simple at the moment but for v1.0.0 a multi-signature account or a simple DAO will be used.

### Solidity libraries

Libraries in Solidity provide the means to deploy an implementation once as a compiled bytecode but without an execution context (storage). Contracts deployed subsequently can then be statically linked to the library.

Our token system takes advantage of this feature to save gas deploying multiple tokens. It can also be argued that sharing audited libraries between contracts can reduce the risk of bugs &mdash; and worst case ease the replacement of a buggy implementation.

### Token Systems

Our tokens are designed as a token system and implemented using Solidity libraries. A token system is a methodology which aims to separate the token into three modules, providing the means for composable and upgradable tokens.

1. *Frontend*

    This contract implements the token standard and provides a permanent Ethereum address for the token system. All method calls on this contract are forwarded to the controller.

2. *Controller*

    The controller is responsible for the business logic, which is implemented as a library. Our controllers are further separated by the functionality they provide into; standard controller, mintable controller and smart controller.

3. *Storage*

    Permanent token storage for controllers. Should the storage layout change in the future a new token storage with the extra data fields referencing the old token storage.


Using this design we're able to upgrade the business logic &mdash; to fix bugs or add functionality &mdash; while providing a fixed address on the blockchain and permanent access to the token bookkeeping.


## Development

To ease the development, deployment and interaction with the token system we're using both testrpc and truffle.

Testrpc simulates full client behavior and makes developing Ethereum applications much faster while Truffle is a development environment, testing framework and asset pipeline for Ethereum.

Development happens on the master branch and we use [Semantic Versioning](http://semver.org) for our tags. The first pre-release version deployed on a non-testrpc blockchain is v0.7.0.


## Deployment

```sh
# truffle migrate [--network <name>]
```

The deployment cycle for beta versions (up to v1.0.0) is as follows. During development the smart contracts are continuously deployed and tested locally on testrpc. A patch version update is deployed on the Monerium testnet, a federated blockchain, run by Monerium. A minor version update is deployed on the Rinkeby testnet.

|  Contract            |  Rinkeby                                     |  Monerium                                    |
|----------------------|----------------------------------------------|----------------------------------------------|
|  BlacklistValidator  |  0x91e729e24d39500a19d08b5257c5c808d3c87b78  |  0xfa709c1d5a468809c291de2b379b02d0e30bddfd  |
|  ERC20Lib            |  0xe7708e44eef5eac6db767c7835629a2f0510ce2a  |  0xe879564d3548c30c22976b0009a9377c387e1118  |
|  EUR                 |  0x26191aacdeef5955c487bd3a75849644673bd408  |  0x2a3589b9e272c92c4d06b46665f04f60443157ef  |
|  Migrations          |  0x5c20b21a5edf44e7a8673675797aa1b2547a0155  |  0xe84c38c2e4af29af65bdb720a8dca1b2bdd08cce  |
|  MintableController  |  0xd1d33736088962699b83707bc4d375333d9d1e50  |  0x4aa03a8be13968199cf6baa5f22dab1221ee8361  |
|  MintableTokenLib    |  0xb375dd49a72a4071428b102a59f45895b7e63e14  |  0x2f131d95a84289470d9618cfd9405c8ab09833e7  |
|  SafeMathLib         |  0x678ff16287ada64e0b5e65524b4d52a23b422e36  |  0x7a8669cf284795724c1bb8f7cdaedd725418d5d6  |
|  SmartController     |  0x8c96c4a76052f9db1dbec9bbf1d81ba4f3d01339  |  0x0264853860bd7835c0f32f6648d1666cff4e974a  |
|  SmartTokenLib       |  0xba98211d2ac02e822bfbc8db2e8843e2e62b546a  |  0xce1d42b62217624acdc4ab263bbca3e9a07917d1  |
|  StandardController  |  0x29686a4c85ebc54e7c1d76a823d6aa53e1b99867  |  0xce5845214a7711620c3ce6f63580e1918bf95b26  |
|  TokenStorage        |  0xee3a30994bd98a5cf49629b459c2f7ac727efd36  |  0x178ec026863bb7a8adbc7f351bfcc956e083a022  |
|  TokenStorageLib     |  0xc752eb408c9aac42c8f578f5ad6bdaaa737770b5  |  0x1734e6ff759a6692fe18a348b2402ee4bf13340a  |
|  USD                 |  0x538523bfe6621b87967e73e9c2ba4fd527abd33a  |  0x5994eeca34dd29cc532c1721a8279556454845ea  |


## Unit tests

The token system ships with JavaScript unit tests.

```sh
# truffle test
```

![Unit tests](docs/test-suite.png)


## Token interface

```javascript
pragma solidity ^0.4.8;
 
// ----------------------------------------------------------------------------------------------
// Sample fixed supply token contract
// Enjoy. (c) BokkyPooBah 2017. The MIT Licence.
// ----------------------------------------------------------------------------------------------
 
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/issues/20
contract ERC20Interface {
    // Get the total token supply
    function totalSupply() constant returns (uint256 totalSupply);
 
    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) constant returns (uint256 balance);
 
    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) returns (bool success);
 
    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
 
    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    // this function is required for some DEX functionality
    function approve(address _spender, uint256 _value) returns (bool success);
 
    // Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
 
    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
 
    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
```


Copyright &copy; 2016-2017, Gísli Kristjánsson for Monerium ehf.
