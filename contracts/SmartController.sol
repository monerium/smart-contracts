pragma solidity 0.4.24;

import "./SmartTokenLib.sol";
import "./MintableController.sol";
import "./IValidator.sol";

/**
 * @title SmartController
 * @dev This contract adds "smart" functionality which is required from a regulatory perspective.
 */
contract SmartController is MintableController {

    using SmartTokenLib for SmartTokenLib.SmartStorage;

    SmartTokenLib.SmartStorage internal smartToken;

    bytes3 public ticker;
    uint constant public INITIAL_SUPPLY = 0;

    /**
     * @dev Contract constructor.
     * @param storage_ Address of the token storage for the controller.
     * @param validator Address of validator.
     * @param ticker_ 3 letter currency ticker.
     * @param frontend_ Address of the authorized frontend.
     */
    constructor(address storage_, address validator, bytes3 ticker_, address frontend_)
        public
        MintableController(storage_, INITIAL_SUPPLY, frontend_) 
    {
        require(validator != 0x0, "validator cannot be the null address");
        smartToken.setValidator(validator);
        ticker = ticker_;
    }

    /**
     * @dev Sets a new validator.
     * @param validator Address of validator.
     */
    function setValidator(address validator) external onlySystemAccounts {
        smartToken.setValidator(validator);
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
    function recover(address from, address to, bytes32 h, uint8 v, bytes32 r, bytes32 s)
        external
        onlySystemAccounts
        returns (bool)
    {
        return SmartTokenLib.recover(token, from, to, h, v, r, s);
    }

    /**
     * @dev Transfers tokens [ERC20]. 
     * See transfer_withCaller for documentation.
     */
    function transfer(address to, uint amount) 
        external 
        returns (bool) 
    {
        return transfer_withCaller(msg.sender, to, amount);
    }

    /**
     * @dev Transfers tokens [ERC20]. 
     * Prior to transfering tokens the validator needs to approve.
     * @param caller Address of the caller passed through the frontend.
     * @param to Recipient address.
     * @param amount Number of tokens to transfer.
     */
    function transfer_withCaller(address caller, address to, uint amount) 
        public 
        whenNotPaused
        returns (bool) 
    {
        require(smartToken.validate(caller, to, amount), "transfer request not valid");
        return super.transfer_withCaller(caller, to, amount);
    }


    /**
     * @dev Gets the current validator.
     * @return Address of validator.
     */
    function getValidator() external view returns (address) {
        return smartToken.getValidator();
    }

}
