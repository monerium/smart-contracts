// SPDX-License-Identifier: APACHE 2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import "../../src/Token.sol";

/**
 * @title Balance
 * @notice Script to check the token balance of an address with simple formatting
 * @dev This is a read-only script that displays balance with specified decimal places
 */
contract Balance is Script {
    function run(address tokenAddress, address account) external view {
        Token token = Token(tokenAddress);
        
        // Get token information
        uint256 rawBalance = token.balanceOf(account);
        uint8 decimals = token.decimals();
        string memory symbol = token.symbol();
        
        // Display basic information
        console2.log("Token:", symbol);
        console2.log("Address:", account);
        
        // Display raw balance (useful for technical purposes)
        console2.log("Balance raw:", rawBalance);
        
        
        // Display balance with 2 decimal places (common format)
        string memory twoDecimalStr = _formatWithDecimals(rawBalance, decimals, 2);
        console2.log("Balance decimal 2:", twoDecimalStr);
    }
    
    /**
     * @dev Format a number with specified decimal places
     * @param value The raw value
     * @param tokenDecimals The token's decimal places
     * @param displayDecimals Number of decimal places to display
     */
    function _formatWithDecimals(uint256 value, uint8 tokenDecimals, uint8 displayDecimals) internal pure returns (string memory) {
        // Handle zero case
        if (value == 0) return "0";
        
        // Ensure display decimals doesn't exceed token decimals
        if (displayDecimals > tokenDecimals) {
            displayDecimals = tokenDecimals;
        }
        
        // Calculate divisor for the whole part
        uint256 divisor = 10 ** tokenDecimals;
        
        // Calculate the whole part
        uint256 wholePart = value / divisor;
        
        // If no decimals needed, just return the whole part
        if (displayDecimals == 0) {
            return vm.toString(wholePart);
        }
        
        // Calculate the fractional part based on display decimals
        uint256 mod = value % divisor;
        
        // Scale the fractional part for display
        uint256 adjFactor = 10 ** (tokenDecimals - displayDecimals);
        uint256 fractionalPart = (mod / adjFactor);
        
        // Format the fractional part to have leading zeros if needed
        string memory fractionalStr = vm.toString(fractionalPart);
        string memory leadingZeros = "";
        
        for (uint8 i = 0; i < displayDecimals - bytes(fractionalStr).length; i++) {
            leadingZeros = string.concat(leadingZeros, "0");
        }
        
        fractionalStr = string.concat(leadingZeros, fractionalStr);
        
        // Return the formatted string
        return string.concat(vm.toString(wholePart), ".", fractionalStr);
    }
}

/**
 * @title Supply
 * @notice Script to check the total supply of a token
 * @dev This is a read-only script
 */
contract Supply is Script {
    function run(address tokenAddress) external view {
        Token token = Token(tokenAddress);
        
        // Get token information
        uint256 totalSupply = token.totalSupply();
        uint8 decimals = token.decimals();
        string memory symbol = token.symbol();
        uint256 divisor = 10 ** decimals;
        
        // Display information
        console2.log("Token Information:");
        console2.log("  Address:", tokenAddress);
        console2.log("  Symbol:", symbol);
        console2.log("  Decimals:", decimals);
        
        console2.log("\nTotal Supply:");
        console2.log("  Raw:", totalSupply);
        
        if (totalSupply > 0) {
            uint256 wholeTokens = totalSupply / divisor;
            uint256 fractionalPart = totalSupply % divisor;
            
            // Format the output to be more readable
            console2.log("  Whole tokens:", wholeTokens, symbol);
            if (fractionalPart > 0) {
                console2.log("  Fractional part:", fractionalPart);
            }
        } else {
            console2.log("  Supply is zero");
        }
    }
}

/**
 * @title Mint
 * @notice Script to mint tokens to an address
 * @dev This requires a private key with minting permissions
 */
contract Mint is Script {
    function run(address tokenAddress, address recipient, uint256 amount) external {
        Token token = Token(tokenAddress);
        
        // Get token information
        uint8 decimals = token.decimals();
        string memory symbol = token.symbol();
        uint256 divisor = 10 ** decimals;
        
        // Display pre-mint information
        console2.log("Token Information:");
        console2.log("  Address:", tokenAddress);
        console2.log("  Symbol:", symbol);
        
        uint256 balanceBefore = token.balanceOf(recipient);
        console2.log("\nBefore minting:");
        console2.log("  Recipient:", recipient);
        console2.log("  Balance:", balanceBefore);
        
        console2.log("\nMinting", amount, "tokens to", recipient);
        
        // Format the amount for display
        if (amount > 0) {
            uint256 wholeTokens = amount / divisor;
            uint256 fractionalPart = amount % divisor;
            
            console2.log("  Amount to mint:", wholeTokens, symbol);
            if (fractionalPart > 0) {
                console2.log("  Fractional part:", fractionalPart);
            }
        }
        
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Mint tokens
        token.mint(recipient, amount);
        
        // End broadcasting
        vm.stopBroadcast();
        
        // Display post-mint information
        uint256 balanceAfter = token.balanceOf(recipient);
        console2.log("\nAfter minting:");
        console2.log("  New balance:", balanceAfter);
        console2.log("  Increase:", balanceAfter - balanceBefore);
        console2.log("\nMinting successful.");
    }
}

/**
 * @title Burn
 * @notice Script to burn tokens from an address
 * @dev This requires a private key with burning permissions and a valid signature
 */
contract Burn is Script {
    function run(address tokenAddress, address fromAddress, uint256 amount, bytes memory signature) external {
        Token token = Token(tokenAddress);
        
        // Get token information
        uint8 decimals = token.decimals();
        string memory symbol = token.symbol();
        uint256 divisor = 10 ** decimals;
        
        // Display pre-burn information
        console2.log("Token Information:");
        console2.log("  Address:", tokenAddress);
        console2.log("  Symbol:", symbol);
        
        uint256 balanceBefore = token.balanceOf(fromAddress);
        console2.log("\nBefore burning:");
        console2.log("  From address:", fromAddress);
        console2.log("  Balance:", balanceBefore);
        
        console2.log("\nBurning", amount, "tokens from", fromAddress);
        
        // Format the amount for display
        if (amount > 0) {
            uint256 wholeTokens = amount / divisor;
            uint256 fractionalPart = amount % divisor;
            
            console2.log("  Amount to burn:", wholeTokens, symbol);
            if (fractionalPart > 0) {
                console2.log("  Fractional part:", fractionalPart);
            }
        }
        
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Burn tokens - using default hash from the token contract
        bytes32 defaultHash = 0xb77c35c892a1b24b10a2ce49b424e578472333ee8d2456234fff90626332c50f;
        token.burn(fromAddress, amount, defaultHash, signature);
        
        // End broadcasting
        vm.stopBroadcast();
        
        // Display post-burn information
        uint256 balanceAfter = token.balanceOf(fromAddress);
        console2.log("\nAfter burning:");
        console2.log("  New balance:", balanceAfter);
        console2.log("  Decrease:", balanceBefore - balanceAfter);
        console2.log("\nBurning successful.");
    }
}

/**
 * @title GetMintAllowance
 * @notice Script to check the mint allowance of an address
 * @dev This is a read-only script
 */
contract GetMintAllowance is Script {
    function run(address tokenAddress, address account) external view {
        Token token = Token(tokenAddress);
        
        // Get allowance information
        uint256 allowance = token.getMintAllowance(account);
        uint256 maxAllowance = token.getMaxMintAllowance();
        uint8 decimals = token.decimals();
        string memory symbol = token.symbol();
        uint256 divisor = 10 ** decimals;
        
        // Display information
        console2.log("Token Information:");
        console2.log("  Address:", tokenAddress);
        console2.log("  Symbol:", symbol);
        
        console2.log("\nMint Allowance for", account, ":");
        console2.log("  Raw:", allowance);
        
        if (allowance > 0) {
            uint256 wholeTokens = allowance / divisor;
            uint256 fractionalPart = allowance % divisor;
            
            // Format the output to be more readable
            console2.log("  Whole tokens:", wholeTokens, symbol);
            if (fractionalPart > 0) {
                console2.log("  Fractional part:", fractionalPart);
            }
        } else {
            console2.log("  Allowance is zero");
        }
        
        console2.log("\nMax Mint Allowance:");
        console2.log("  Raw:", maxAllowance);
        
        if (maxAllowance > 0) {
            uint256 wholeTokens = maxAllowance / divisor;
            uint256 fractionalPart = maxAllowance % divisor;
            
            // Format the output to be more readable
            console2.log("  Whole tokens:", wholeTokens, symbol);
            if (fractionalPart > 0) {
                console2.log("  Fractional part:", fractionalPart);
            }
        } else {
            console2.log("  Max allowance is zero");
        }
    }
}

/**
 * @title SetMaxMintAllowance
 * @notice Script to set the maximum mint allowance
 * @dev This requires a private key with owner permissions
 */
contract SetMaxMintAllowance is Script {
    function run(address tokenAddress, uint256 amount) external {
        Token token = Token(tokenAddress);
        
        // Get token information
        uint8 decimals = token.decimals();
        string memory symbol = token.symbol();
        uint256 divisor = 10 ** decimals;
        
        // Display pre-update information
        uint256 maxAllowanceBefore = token.getMaxMintAllowance();
        console2.log("Token Information:");
        console2.log("  Address:", tokenAddress);
        console2.log("  Symbol:", symbol);
        
        console2.log("\nBefore update:");
        console2.log("  Current max allowance:", maxAllowanceBefore);
        
        console2.log("\nSetting max mint allowance to", amount);
        
        // Format the amount for display
        if (amount > 0) {
            uint256 wholeTokens = amount / divisor;
            uint256 fractionalPart = amount % divisor;
            
            console2.log("  New max allowance:", wholeTokens, symbol);
            if (fractionalPart > 0) {
                console2.log("  Fractional part:", fractionalPart);
            }
        }
        
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Set max mint allowance
        token.setMaxMintAllowance(amount);
        
        // End broadcasting
        vm.stopBroadcast();
        
        // Display post-update information
        uint256 maxAllowanceAfter = token.getMaxMintAllowance();
        console2.log("\nAfter update:");
        console2.log("  New max allowance:", maxAllowanceAfter);
        console2.log("\nUpdate successful.");
    }
}

/**
 * @title SetMintAllowance
 * @notice Script to set the mint allowance for an account
 * @dev This requires a private key with admin permissions
 */
contract SetMintAllowance is Script {
    function run(address tokenAddress, address account, uint256 amount) external {
        Token token = Token(tokenAddress);
        
        // Get token information
        uint8 decimals = token.decimals();
        string memory symbol = token.symbol();
        uint256 divisor = 10 ** decimals;
        
        // Display pre-update information
        uint256 allowanceBefore = token.getMintAllowance(account);
        console2.log("Token Information:");
        console2.log("  Address:", tokenAddress);
        console2.log("  Symbol:", symbol);
        
        console2.log("\nBefore update:");
        console2.log("  Account:", account);
        console2.log("  Current allowance:", allowanceBefore);
        
        console2.log("\nSetting mint allowance to", amount);
        
        // Format the amount for display
        if (amount > 0) {
            uint256 wholeTokens = amount / divisor;
            uint256 fractionalPart = amount % divisor;
            
            console2.log("  New allowance:", wholeTokens, symbol);
            if (fractionalPart > 0) {
                console2.log("  Fractional part:", fractionalPart);
            }
        }
        
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Set mint allowance
        token.setMintAllowance(account, amount);
        
        // End broadcasting
        vm.stopBroadcast();
        
        // Display post-update information
        uint256 allowanceAfter = token.getMintAllowance(account);
        console2.log("\nAfter update:");
        console2.log("  New allowance:", allowanceAfter);
        console2.log("\nUpdate successful.");
    }
}
