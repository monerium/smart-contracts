# Monerium's e-money Token Design

Monerium's token adheres to the ERC-20 standard, supporting multi-entity minting and burning, address-specific freezing, and contract upgradeability for future feature enhancements and code modifications.

## Roles

Monerium's token is being managed by three roles which own responsibilities over different functionalities: 

#### Owner

  * Only one address, managed by a Gnosis multi-sig safe.
  * Adds and removes `admin` and `system` addresses.
  * Set the cap for Minting allowances.
  * Adds or removes Validators

#### Admin
  
  * Can be multiple addresses.
  * Only one admin address is used. Managed by multi-sig Gnosis managed by Monerium's administrators.
  * Increases `system` addresses's minting allowance.
  * Adds and removes addresses to/from the blacklist.

#### System

  * Can be multiple addresses.
  * EOA address used by Monerium's infrastructure to issue or redeem e-money tokens by minting and burning.

Monerium's token management includes transparent role modifications, tracked by events like `SystemAccountAdded`, `SystemAccountRemoved`, `AdminAccountAdded`, and `AdminAccountRemoved`. 

## ERC20 

All four tokens implement the standard method of the ERC-20 interface.

- `totalSupply()`
- `balanceOf(address _owner)`
- `transfer(address _to, uint256 _value)`
- `transferFrom(address _from, address _to, uint256 _value)`
- `approve(address _spender, uint256 _value)`
- `allowance(address _owner, address _spender)`

## Issuing and Redeeming Tokens 

Monerium tokens are a 1:1 backed e-money, Issuing and Redeeming money happens when the money comes and goes into your Monerium's account through your Monerium's IBAN.

### Minting Process

When funds are received on a user's associated Monerium IBAN, it enables token minting by system role accounts, with mint allowances controlled by admin accounts through a Gnosis MultiSig wallet.

### Burning Process

Token burning occurs upon redemption, requiring the token holder's signature for validation. This secure approach ensures that only user-authorized redemptions proceed.

### Fund Recovery Process

If access to a wallet is lost, Monerium provides a mechanism to recover funds thanks to the initial signature provided by the wallet owner at linkage. This capability is embodied in the [recover](https://github.com/monerium/smart-contracts/blob/0dba368cb2c7c037cbc80326e5b8eb61cf5f2b1e/src/Token.sol#L86) function, allowing the secure transfer of funds from an inaccessible wallet to a new one. 

