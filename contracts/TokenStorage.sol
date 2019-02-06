pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/ownership/Claimable.sol";
import "openzeppelin-solidity/contracts/ownership/CanReclaimToken.sol";
import "openzeppelin-solidity/contracts/ownership/NoOwner.sol";
import "./TokenStorageLib.sol";

/**
 * @title TokenStorage
 * @dev External storage for tokens.
 * The storage is implemented in a separate contract to maintain state
 * between token upgrades.
 */
contract TokenStorage is Claimable, CanReclaimToken, NoOwner {

    using TokenStorageLib for TokenStorageLib.TokenStorage;

    TokenStorageLib.TokenStorage tokenStorage;

    /**
     * @dev Increases balance of an address.
     * @param to Address to increase.
     * @param amount Number of units to add.
     */
    function addBalance(address to, uint amount) external onlyOwner {
        tokenStorage.addBalance(to, amount);
    }

    /**
     * @dev Decreases balance of an address.
     * @param from Address to decrease.
     * @param amount Number of units to subtract.
     */
    function subBalance(address from, uint amount) external onlyOwner {
        tokenStorage.subBalance(from, amount);
    }

    /**
     * @dev Sets the allowance for a spender.
     * @param owner Address of the owner of the tokens to spend.
     * @param spender Address of the spender.
     * @param amount Qunatity of allowance.
     */
    function setAllowed(address owner, address spender, uint amount) external onlyOwner {
        tokenStorage.setAllowed(owner, spender, amount);
    }

    /**
     * @dev Returns the supply of tokens.
     * @return Total supply.
     */
    function getSupply() external view returns (uint) {
        return tokenStorage.getSupply();
    }

    /**
     * @dev Returns the balance of an address.
     * @param who Address to lookup.
     * @return Number of units.
     */
    function getBalance(address who) external view returns (uint) {
        return tokenStorage.getBalance(who);
    }

    /**
     * @dev Returns the allowance for a spender.
     * @param owner Address of the owner of the tokens to spend.
     * @param spender Address of the spender.
     * @return Number of units.
     */
    function getAllowed(address owner, address spender) 
        external 
        view 
        returns (uint)
    {
        return tokenStorage.getAllowed(owner, spender);
    }

}
