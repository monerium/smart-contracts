pragma solidity ^0.4.24;


// import "zeppelin-solidity/contracts/token/EternalTokenStorage.sol";
import "zeppelin-solidity/contracts/SafeMathLib.sol";
import "./TokenStorage.sol";


/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

library MintableTokenLib {
    using SafeMathLib for uint;

    event Mint(address indexed to, uint amount);
    event Burn(address indexed from, uint amount);

    /**
     * @dev Function to mint tokens
     * @param _to The address that will recieve the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    // function mint(address _to, uint _amount) onlyOwner canMint returns (bool) {
    function mint(
        TokenStorage self, 
        address _to, 
        uint _amount
    ) 
        external 
        view 
        returns (bool) 
    {
        self.addBalance(_to, _amount);
        emit Mint(_to, _amount);
        return true;
    }
    
    function burn(
        TokenStorage self, 
        address _from, 
        uint _amount
    ) 
        external
        view 
        returns (bool) 
    {
        self.subBalance(_from, _amount);
        emit Burn(_from, _amount);
        return true;
    }

}

