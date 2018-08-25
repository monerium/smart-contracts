pragma solidity ^0.4.24;

import "./ERC20Lib.sol";
import "./MintableTokenLib.sol";
import "./IValidator.sol";

/**
 * @title SmartTokenLib
 * @dev This library provides functionality which is required from a regulatory perspective.
 */
library SmartTokenLib {

    using ERC20Lib for TokenStorage;
    using MintableTokenLib for TokenStorage;

    struct SmartStorage {
        IValidator validator;
    }

    /**
     * @dev Emitted when the contract owner recovers tokens.
     * @param from Sender address.
     * @param to Recipient address.
     * @param amount Number of tokens.
     */
    event Recovered(address indexed from, address indexed to, uint amount);

    /**
     * @dev Sets a new validator.
     * @param self Smart storage to operate on.
     * @param validator Address of validator.
     */
    function setValidator(SmartStorage storage self, address validator) 
        internal 
    {
        self.validator = IValidator(validator);
    }


    /**
     * @dev Approves or rejects a transfer request.
     * The request is forwarded to a validator which implements
     * the actual business logic.
     * @param self Smart storage to operate on.
     * @param from Sender address.
     * @param to Recipient address.
     * @param amount Number of tokens.
     */
    function validate(SmartStorage storage self, address from, address to, uint amount) 
        internal
        returns (bool valid) 
    { 
        return self.validator.validate(from, to, amount);
    }

    /**
     * @dev Sets a new validator.
     * @param self Smart storage to operate on.
     * @param validator Address of validator.
     */
    function setValidator(SmartStorage storage self, address validator) 
        internal 
    {
        self.validator = IValidator(validator);
    }


    /**
     * @dev Approves or rejects a transfer request.
     * The request is forwarded to a validator which implements
     * the actual business logic.
     * @param self Smart storage to operate on.
     * @param from Sender address.
     * @param to Recipient address.
     * @param amount Number of tokens.
     */
    function validate(SmartStorage storage self, address from, address to, uint amount) 
        internal
        returns (bool valid) 
    { 
        return self.validator.validate(from, to, amount);
    }

    /**
     * @dev Recovers tokens from an address and reissues them to another address.
     * In case a user loses its private key the tokens can be recovered by burning
     * the tokens from that address and reissuing to a new address.
     * To recover tokens the contract owner needs to provide a signature
     * proving that the token owner has authorized the owner to do so.
     * @param from Address to burn tokens from.
     * @param to Address to mint tokens to.
     * @param h Hash which the token owner signed.
     * @param v Signature component.
     * @param r Signature component.
     * @param s Sigature component.
     */
    function recover(
        TokenStorage token, 
        address from, 
        address to, 
        bytes32 h, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) 
        internal 
        returns (bool) 
    {
        require(
            ecrecover(h, v, r, s) == from,
            "signature/hash does not recover from address"
        );
        uint amount = token.balanceOf(from);
        require(token.burn(from, amount), "unable to burn tokens");
        require(token.mint(to, amount), "unable to mint tokens"); 
        emit Recovered(from, to, amount);
        return true;
    }

    /**
     * @dev Gets the current validator.
     * @param self Smart storage to operate on.
     * @return Address of validator.
     */
    function getValidator(SmartStorage storage self) 
        external 
        view 
        returns (address) 
    {
        return address(self.validator);
    }

}
