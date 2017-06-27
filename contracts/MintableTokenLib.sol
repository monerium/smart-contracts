pragma solidity ^0.4.11;


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
    // event MintFinished();

    // bool public mintingFinished = false;


    // modifier canMint() {
        // if(mintingFinished) throw;
        // _;
    // }

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
    ) constant returns (bool) {
        // self.totalSupply = self.totalSupply.plus(_amount);
        // self.balances[_to] = self.balances[_to].plus(_amount);
        self.addBalance(_to, _amount);
        Mint(_to, _amount);
        return true;
    }
    
    function burn(
        TokenStorage self, 
        address _from, 
        uint _amount
    ) constant returns (bool) {
        // self.totalSupply = self.totalSupply.minus(_amount);
        // self.balances[_from] = self.balances[_from].minus(_amount);
        self.subBalance(_from, _amount);
        Burn(_from, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    // function finishMinting() onlyOwner returns (bool) {
//    function finishMinting() constant returns (bool) {
//        mintingFinished = true;
//        MintFinished();
//        return true;
//    }
}

