pragma solidity ^0.4.24;

import "./SmartTokenLib.sol";
import "./MintableController.sol";
import "./Validator.sol";

contract SmartController is MintableController {

    using SmartTokenLib for SmartTokenLib.SmartTokenStorage;
    using MintableTokenLib for SmartTokenLib.SmartTokenStorage;

    SmartTokenLib.SmartTokenStorage smartToken;

    bytes3 public ticker;
    uint public decimals = 18;
    uint constant public INITIAL_SUPPLY = 0;

    // EVENTS
    event Recovered(address indexed from, address indexed to, uint amount);

    // CONSTRUCTOR
    constructor(address _storage, address validator, bytes3 ticker_)
        public
        MintableController(_storage, INITIAL_SUPPLY) 
    {
        assert(validator != 0x0);
        smartToken.setValidator(validator);
        ticker = ticker_;
    }

    // EXTERNAL
    function setValidator(address validator) external {
        smartToken.setValidator(validator);
    }

    function recover(address from, address to, bytes32 h, uint8 v, bytes32 r, bytes32 s)
        external
        onlyOwner
        returns (bool)
    {
        require(
            SmartTokenLib.recover(from, h, v, r, s), 
            "signature/hash does not recover from address"
        );
        uint amount = this.balanceOf(from);
        require(token.burn(from, amount), "unable to burn tokens");
        require(token.mint(to, amount), "unable to mint tokens"); 
        emit Recovered(from, to, amount);
        return true;
    }

    // EXTERNAL ERC20
    function transfer(address to, uint value) external returns (bool ok) {
        return transfer20(msg.sender, to, value);
    }

    // PUBLIC ERC20 FRONT
    function transfer20(address _caller, address to, uint value) 
        public 
        returns (bool ok) 
    {
        if (!smartToken.validate(_caller, to, value)) {
            revert("transfer is not valid");
        }
        return super.transfer20(_caller, to, value);
    }

    // EXTERNAL CONSTANT
    function getValidator() external view returns (address) {
        return smartToken.getValidator();
    }

}
