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

## ERC20 

All four tokens implement the standard method of the ERC-20 interface.

## Issuing and Redeeming Tokens 

Monerium tokens as a 1:1 backed e-money, Issuing and Redeeming money happens when the money comes and go into your monerium's account through your Monerium's IBAN.
