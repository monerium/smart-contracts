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
    uint public INITIAL_SUPPLY = 0;

    // EVENTS
    event Recovered(address indexed from, address indexed to, uint amount);

    // CONSTRUCTOR
    constructor(address _storage, address _validator, bytes3 _ticker)
        public
        MintableController(_storage, INITIAL_SUPPLY) 
    {
        assert(_validator != 0x0);
        smartToken.setValidator(_validator);
        ticker = _ticker;
    }

    // EXTERNAL
    function setValidator(address _validator) external {
        smartToken.setValidator(_validator);
    }

    function recover(address from, address to, bytes32 h, uint8 v, bytes32 r, bytes32 s)
        external
        onlyOwner
        returns (bool)
    {
        require(SmartTokenLib.recover(from, h, v, r, s), "signature/hash does not recover from address");
        uint amount = this.balanceOf(from);
        require(token.burn(from, amount));
        require(token.mint(to, amount)); 
        emit Recovered(from, to, amount);
        return true;
    }

    // PUBLIC ERC20 FRONT
    function _transfer(address _caller, address to, uint value) 
        public 
        returns (bool ok) 
    {
        if (!smartToken.validate(_caller, to, value)) {
            revert("transfer is not valid");
        }
        return super.transfer(_caller, to, value);
    }

    // EXTERNAL CONSTANT
    function getValidator() external view returns (address) {
        return smartToken.getValidator();
    }
}
