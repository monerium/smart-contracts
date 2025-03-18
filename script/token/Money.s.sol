// SPDX-License-Identifier: APACHE 2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import "../../src/Token.sol";

/**
 * @title MoneyBaseScript
 * @notice Base contract that provides common formatting functionality
 * @dev Other money-related scripts inherit from this to avoid code duplication
 */
contract MoneyBaseScript is Script {
    /**
     * @dev Format a number with specified decimal places
     * @param value The raw value
     * @param tokenDecimals The token's decimal places
     * @param displayDecimals Number of decimal places to display
     * @return Formatted string representation with specified decimal places
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
 * @title Balance
 * @notice Script to check the token balance of an address with simple formatting
 * @dev This is a read-only script that displays balance with 2 decimal places
 */
contract Balance is MoneyBaseScript {
    function run(address tokenAddress, address account) external view {
        Token token = Token(tokenAddress);
        
        // Get token information
        uint256 rawBalance = token.balanceOf(account);
        uint8 decimals = token.decimals();
        
        // Display balance in simplified format
        console2.log("Raw:", rawBalance);
        console2.log("Decimal 2:", _formatWithDecimals(rawBalance, decimals, 2));
    }
}

/**
 * @title Supply
 * @notice Script to check the total supply of a token
 * @dev This is a read-only script that displays supply with 2 decimal places
 */
contract Supply is MoneyBaseScript {
    function run(address tokenAddress) external view {
        Token token = Token(tokenAddress);
        
        // Get token information
        uint256 totalSupply = token.totalSupply();
        uint8 decimals = token.decimals();
        
        // Display supply in simplified format
        console2.log("Raw:", totalSupply);
        console2.log("Decimal 2:", _formatWithDecimals(totalSupply, decimals, 2));
    }
}

/**
 * @title Mint
 * @notice Script to mint tokens to an address
 * @dev This requires a private key with minting permissions
 */
contract Mint is MoneyBaseScript {
    function run(address tokenAddress, address recipient, uint256 amount) external {
        Token token = Token(tokenAddress);
        
        // Get token information
        uint8 decimals = token.decimals();
        
        // Display pre-mint information
        uint256 balanceBefore = token.balanceOf(recipient);
        console2.log("Before Mint - Raw:", balanceBefore);
        console2.log("Before Mint - Decimal 2:", _formatWithDecimals(balanceBefore, decimals, 2));
        
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Mint tokens
        token.mint(recipient, amount);
        
        // End broadcasting
        vm.stopBroadcast();
        
        // Display post-mint information
        uint256 balanceAfter = token.balanceOf(recipient);
        console2.log("After Mint - Raw:", balanceAfter);
        console2.log("After Mint - Decimal 2:", _formatWithDecimals(balanceAfter, decimals, 2));
    }
}

/**
 * @title Burn
 * @notice Script to burn tokens from an address
 * @dev This requires a private key with burning permissions and a valid signature
 */
contract Burn is MoneyBaseScript {
    function run(address tokenAddress, address fromAddress, uint256 amount, bytes memory signature) external {
        Token token = Token(tokenAddress);
        
        // Get token information
        uint8 decimals = token.decimals();
        
        // Display pre-burn information
        uint256 balanceBefore = token.balanceOf(fromAddress);
        console2.log("Before Burn - Raw:", balanceBefore);
        console2.log("Before Burn - Decimal 2:", _formatWithDecimals(balanceBefore, decimals, 2));
        
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Burn tokens - using default hash from the token contract
        bytes32 defaultHash = 0xb77c35c892a1b24b10a2ce49b424e578472333ee8d2456234fff90626332c50f;
        token.burn(fromAddress, amount, defaultHash, signature);
        
        // End broadcasting
        vm.stopBroadcast();
        
        // Display post-burn information
        uint256 balanceAfter = token.balanceOf(fromAddress);
        console2.log("After Burn - Raw:", balanceAfter);
        console2.log("After Burn - Decimal 2:", _formatWithDecimals(balanceAfter, decimals, 2));
    }
}

/**
 * @title GetMintAllowance
 * @notice Script to check the mint allowance of an account
 * @dev This is a read-only script
 */
contract GetMintAllowance is MoneyBaseScript {
    function run(address tokenAddress, address account) external view {
        Token token = Token(tokenAddress);
        
        // Get allowance information
        uint256 allowance = token.getMintAllowance(account);
        uint8 decimals = token.decimals();
        
        // Display information in simplified format
        console2.log("Raw:", allowance);
        console2.log("Decimal 2:", _formatWithDecimals(allowance, decimals, 2));
    }
}

/**
 * @title GetMaxMintAllowance
 * @notice Script to check the maximum mint allowance
 * @dev This is a read-only script
 */
contract GetMaxMintAllowance is MoneyBaseScript {
    function run(address tokenAddress) external view {
        Token token = Token(tokenAddress);
        
        // Get max allowance information
        uint256 maxAllowance = token.getMaxMintAllowance();
        uint8 decimals = token.decimals();
        
        // Display information in simplified format
        console2.log("Raw:", maxAllowance);
        console2.log("Decimal 2:", _formatWithDecimals(maxAllowance, decimals, 2));
    }
}

/**
 * @title SetMaxMintAllowance
 * @notice Script to set the maximum mint allowance
 * @dev This requires a private key with owner permissions
 */
contract SetMaxMintAllowance is MoneyBaseScript {
    function run(address tokenAddress, uint256 amount) external {
        Token token = Token(tokenAddress);
        
        // Get token information
        uint8 decimals = token.decimals();
        
        // Display pre-update information
        uint256 maxAllowanceBefore = token.getMaxMintAllowance();
        console2.log("Before Update - Raw:", maxAllowanceBefore);
        console2.log("Before Update - Decimal 2:", _formatWithDecimals(maxAllowanceBefore, decimals, 2));
        
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Set max mint allowance
        token.setMaxMintAllowance(amount);
        
        // End broadcasting
        vm.stopBroadcast();
        
        // Display post-update information
        uint256 maxAllowanceAfter = token.getMaxMintAllowance();
        console2.log("After Update - Raw:", maxAllowanceAfter);
        console2.log("After Update - Decimal 2:", _formatWithDecimals(maxAllowanceAfter, decimals, 2));
    }
}

/**
 * @title SetMintAllowance
 * @notice Script to set the mint allowance for an account
 * @dev This requires a private key with admin permissions
 */
contract SetMintAllowance is MoneyBaseScript {
    function run(address tokenAddress, address account, uint256 amount) external {
        Token token = Token(tokenAddress);
        
        // Get token information
        uint8 decimals = token.decimals();
        
        // Display pre-update information
        uint256 allowanceBefore = token.getMintAllowance(account);
        console2.log("Before Update - Raw:", allowanceBefore);
        console2.log("Before Update - Decimal 2:", _formatWithDecimals(allowanceBefore, decimals, 2));
        
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Set mint allowance
        token.setMintAllowance(account, amount);
        
        // End broadcasting
        vm.stopBroadcast();
        
        // Display post-update information
        uint256 allowanceAfter = token.getMintAllowance(account);
        console2.log("After Update - Raw:", allowanceAfter);
        console2.log("After Update - Decimal 2:", _formatWithDecimals(allowanceAfter, decimals, 2));
    }
}

/**
 * @title AdminCheck
 * @notice Script to check if an account has admin role
 * @dev This is a read-only script that returns a boolean
 */
contract CheckAdmin is MoneyBaseScript {
    function run(address tokenAddress, address account) external view {
        Token token = Token(tokenAddress);
        
        // Check admin status
        bool isAdmin = token.isAdminAccount(account);
        
        // Display simplified output
        console2.log("Admin Status:", isAdmin);
    }
}

/**
 * @title AddAdmin
 * @notice Script to add an account to admin role
 * @dev This requires a private key with owner permissions
 */
contract AddAdmin is MoneyBaseScript {
    function run(address tokenAddress, address account) external {
        Token token = Token(tokenAddress);
        
        // Display pre-update status
        bool statusBefore = token.isAdminAccount(account);
        console2.log("Before Update - Admin Status:", statusBefore);
        
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Add admin role
        token.addAdminAccount(account);
        
        // End broadcasting
        vm.stopBroadcast();
        
        // Display post-update status
        bool statusAfter = token.isAdminAccount(account);
        console2.log("After Update - Admin Status:", statusAfter);
    }
}

/**
 * @title RemoveAdmin
 * @notice Script to remove an account from admin role
 * @dev This requires a private key with owner permissions
 */
contract RemoveAdmin is MoneyBaseScript {
    function run(address tokenAddress, address account) external {
        Token token = Token(tokenAddress);
        
        // Display pre-update status
        bool statusBefore = token.isAdminAccount(account);
        console2.log("Before Update - Admin Status:", statusBefore);
        
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Remove admin role
        token.removeAdminAccount(account);
        
        // End broadcasting
        vm.stopBroadcast();
        
        // Display post-update status
        bool statusAfter = token.isAdminAccount(account);
        console2.log("After Update - Admin Status:", statusAfter);
    }
}

/**
 * @title CheckSystem
 * @notice Script to check if an account has system role
 * @dev This is a read-only script that returns a boolean
 */
contract CheckSystem is MoneyBaseScript {
    function run(address tokenAddress, address account) external view {
        Token token = Token(tokenAddress);
        
        // Check system status
        bool isSystem = token.isSystemAccount(account);
        
        // Display simplified output
        console2.log("System Status:", isSystem);
    }
}

/**
 * @title AddSystem
 * @notice Script to add an account to system role
 * @dev This requires a private key with owner permissions
 */
contract AddSystem is MoneyBaseScript {
    function run(address tokenAddress, address account) external {
        Token token = Token(tokenAddress);
        
        // Display pre-update status
        bool statusBefore = token.isSystemAccount(account);
        console2.log("Before Update - System Status:", statusBefore);
        
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Add system role
        token.addSystemAccount(account);
        
        // End broadcasting
        vm.stopBroadcast();
        
        // Display post-update status
        bool statusAfter = token.isSystemAccount(account);
        console2.log("After Update - System Status:", statusAfter);
    }
}

/**
 * @title RemoveSystem
 * @notice Script to remove an account from system role
 * @dev This requires a private key with owner permissions
 */
contract RemoveSystem is MoneyBaseScript {
    function run(address tokenAddress, address account) external {
        Token token = Token(tokenAddress);
        
        // Display pre-update status
        bool statusBefore = token.isSystemAccount(account);
        console2.log("Before Update - System Status:", statusBefore);
        
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Remove system role
        token.removeSystemAccount(account);
        
        // End broadcasting
        vm.stopBroadcast();
        
        // Display post-update status
        bool statusAfter = token.isSystemAccount(account);
        console2.log("After Update - System Status:", statusAfter);
    }
}

/**
 * @title GetValidator
 * @notice Script to get the validator address
 * @dev This is a read-only script
 */
contract GetValidator is MoneyBaseScript {
    function run(address tokenAddress) external view {
        Token token = Token(tokenAddress);
        
        // Get validator address
        address validatorAddress = address(token.validator());
        
        // Display simplified output
        console2.log("Validator Address:", validatorAddress);
    }
}

/**
 * @title SetValidator
 * @notice Script to set the validator address
 * @dev This requires a private key with owner permissions
 */
contract SetValidator is MoneyBaseScript {
    function run(address tokenAddress, address validatorAddress) external {
        Token token = Token(tokenAddress);
        
        // Display pre-update validator
        address validatorBefore = address(token.validator());
        console2.log("Before Update - Validator Address:", validatorBefore);
        
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Set validator
        token.setValidator(validatorAddress);
        
        // End broadcasting
        vm.stopBroadcast();
        
        // Display post-update validator
        address validatorAfter = address(token.validator());
        console2.log("After Update - Validator Address:", validatorAfter);
    }
}

/**
 * @title Owner
 * @notice Script to get the owner of the token contract
 * @dev This is a read-only script
 */
contract Owner is MoneyBaseScript {
    function run(address tokenAddress) external view {
        Token token = Token(tokenAddress);
        
        // Get owner address
        address ownerAddress = token.owner();
        
        // Display simplified output
        console2.log("Owner Address:", ownerAddress);
    }
}

/**
 * @title PendingOwner
 * @notice Script to get the pending owner of the token contract
 * @dev This is a read-only script
 */
contract PendingOwner is MoneyBaseScript {
    function run(address tokenAddress) external view {
        Token token = Token(tokenAddress);
        
        // Get pending owner address
        address pendingOwnerAddress = token.pendingOwner();
        
        // Display simplified output
        console2.log("Pending Owner Address:", pendingOwnerAddress);
    }
}

/**
 * @title TransferOwnership
 * @notice Script to transfer ownership of the token contract
 * @dev This requires a private key with owner permissions
 */
contract TransferOwnership is MoneyBaseScript {
    function run(address tokenAddress, address newOwner) external {
        Token token = Token(tokenAddress);
        
        // Display pre-update owner and pending owner
        address ownerBefore = token.owner();
        address pendingOwnerBefore = token.pendingOwner();
        console2.log("Before Update - Owner Address:", ownerBefore);
        console2.log("Before Update - Pending Owner Address:", pendingOwnerBefore);
        
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Transfer ownership
        token.transferOwnership(newOwner);
        
        // End broadcasting
        vm.stopBroadcast();
        
        // Display post-update owner and pending owner
        address ownerAfter = token.owner();
        address pendingOwnerAfter = token.pendingOwner();
        console2.log("After Update - Owner Address:", ownerAfter);
        console2.log("After Update - Pending Owner Address:", pendingOwnerAfter);
    }
}

/**
 * @title AcceptOwnership
 * @notice Script to accept ownership of the token contract
 * @dev This requires a private key of the pending owner
 */
contract AcceptOwnership is MoneyBaseScript {
    function run(address tokenAddress) external {
        Token token = Token(tokenAddress);
        
        // Display pre-update owner and pending owner
        address ownerBefore = token.owner();
        address pendingOwnerBefore = token.pendingOwner();
        console2.log("Before Update - Owner Address:", ownerBefore);
        console2.log("Before Update - Pending Owner Address:", pendingOwnerBefore);
        
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Accept ownership
        token.acceptOwnership();
        
        // End broadcasting
        vm.stopBroadcast();
        
        // Display post-update owner and pending owner
        address ownerAfter = token.owner();
        address pendingOwnerAfter = token.pendingOwner();
        console2.log("After Update - Owner Address:", ownerAfter);
        console2.log("After Update - Pending Owner Address:", pendingOwnerAfter);
    }
}
