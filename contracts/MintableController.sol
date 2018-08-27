pragma solidity ^0.4.24;

// import "openzeppelin-solidity/contracts/ECRecovery.sol";
import "./StandardController.sol";
import "./MintableTokenLib.sol";

/**
* @title MintableController
* @dev This contracts implements functionality allowing for minting and burning of tokens. 
*/
contract MintableController is StandardController {

    using MintableTokenLib for TokenStorage;

    /**
     * @dev Contract constructor.
     * @param storage_ Address of the token storage for the controller.
     * @param initialSupply The amount of tokens to mint upon creation. 
     */
    constructor(address storage_, uint initialSupply) 
        public
        StandardController(storage_, initialSupply) 
    { }

    /**
     * @dev Mints new tokens to the contract owner.
     * This is a convenience method for mintTo.
     * @param amount Number of tokens to mint.
     */
    function mint(uint amount) external onlyOwner returns (bool) {
        return token.mint(owner, amount);
    }

    /**
     * @dev Mints new tokens.
     * @param to Address to credit the tokens.
     * @param amount Number of tokens to mint.
     */
    function mintTo(address to, uint amount)
        external
        onlyOwner
        returns (bool)
    {
        return token.mint(to, amount);
    }
    
    /**
     * @dev Burns tokens from the contract owner.
     * This removes the burned tokens from circulation.
     * @param amount Number of tokens to burn.
     */
    function burn(uint amount) external onlyOwner returns (bool) {
        return token.burn(owner, amount);
    }

    /**
     * @dev Burns tokens from token owner.
     * To burn tokens the contract owner needs to provide a signature
     * proving that the token owner has authorized the owner to do so.
     * @param from Address of the token owner.
     * @param amount Number of tokens to burn.
     * @param height Signature expires at this blockheight.
     * @param v Signature component.
     * @param r Signature component.
     * @param s Sigature component.
     */
    function burnFrom(
        address from,
        uint amount,
        uint height,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        onlyOwner
        returns (bool)
    {
        bytes32 h = toEthereumSignedMessage(height);
        require(
            ecrecover(h, v, r, s) == from,
            "signature/hash does not recover from address"
        );
        // require(
            // block.number < height,
            // "signature only valid before block"
        // );
        return token.burn(from, amount);
    }

    // @dev Hashes the signed message
    // @ref https://github.com/ethereum/go-ethereum/issues/3731#issuecomment-293866868
    function toEthereumSignedMessage(uint num) internal pure returns (bytes32) {
        string memory msg_ = uint2str(num);
        uint len = bytes(msg_).length;
        require(len > 0, "message must be non-zero");
        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        return keccak256(abi.encodePacked(prefix, uint2str(len), msg_));
    }

    function uint2str(uint i) internal pure returns (string) {
        if (i == 0) return "0";
        uint i1 = i;
        uint j = i1;
        uint len;
        while (j != 0){
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i1 != 0){
            bstr[k--] = byte(48 + i1 % 10);
            i1 /= 10;
        }
        return string(bstr);
    }

}
