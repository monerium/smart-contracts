// SPDX-License-Identifier: APACHE 2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import "../../src/Token.sol";

/**
 * @title CheckAdmin
 * @notice Script to check if an address has admin role
 * @dev This is a read-only script
 */
contract CheckAdmin is Script {
    function run(address tokenAddress, address account) external view {
        Token token = Token(tokenAddress);
        
        bool isAdmin = token.isAdminAccount(account);
        
        console2.log("Contract address:", tokenAddress);
        console2.log("Account:", account);
        console2.log("Is admin:", isAdmin);
    }
}

/**
 * @title CheckSystem
 * @notice Script to check if an address has system role
 * @dev This is a read-only script
 */
contract CheckSystem is Script {
    function run(address tokenAddress, address account) external view {
        Token token = Token(tokenAddress);
        
        bool isSystem = token.isSystemAccount(account);
        
        console2.log("Contract address:", tokenAddress);
        console2.log("Account:", account);
        console2.log("Is system account:", isSystem);
    }
}

/**
 * @title AddAdmin
 * @notice Script to add an address to the admin role
 * @dev This requires a private key with owner permissions
 */
contract AddAdmin is Script {
    function run(address tokenAddress, address account) external {
        Token token = Token(tokenAddress);
        
        // Check current state
        bool isAdminBefore = token.isAdminAccount(account);
        
        console2.log("Contract address:", tokenAddress);
        console2.log("Account to add as admin:", account);
        console2.log("Is already admin:", isAdminBefore);
        
        // Skip if already an admin
        if (isAdminBefore) {
            console2.log("\nAccount is already an admin. No action needed.");
            return;
        }
        
        console2.log("\nAdding account as admin...");
        
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Add admin
        token.addAdminAccount(account);
        
        // End broadcasting
        vm.stopBroadcast();
        
        // Verify the change
        bool isAdminAfter = token.isAdminAccount(account);
        console2.log("\nAfter update:");
        console2.log("Is admin now:", isAdminAfter);
        
        if (isAdminAfter) {
            console2.log("\nSuccessfully added account as admin.");
        } else {
            console2.log("\nFailed to add account as admin.");
        }
    }
}

/**
 * @title RemoveAdmin
 * @notice Script to remove an address from the admin role
 * @dev This requires a private key with owner permissions
 */
contract RemoveAdmin is Script {
    function run(address tokenAddress, address account) external {
        Token token = Token(tokenAddress);
        
        // Check current state
        bool isAdminBefore = token.isAdminAccount(account);
        
        console2.log("Contract address:", tokenAddress);
        console2.log("Account to remove from admin:", account);
        console2.log("Is admin:", isAdminBefore);
        
        // Skip if not an admin
        if (!isAdminBefore) {
            console2.log("\nAccount is not an admin. No action needed.");
            return;
        }
        
        console2.log("\nRemoving account from admin role...");
        
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Remove admin
        token.removeAdminAccount(account);
        
        // End broadcasting
        vm.stopBroadcast();
        
        // Verify the change
        bool isAdminAfter = token.isAdminAccount(account);
        console2.log("\nAfter update:");
        console2.log("Is admin now:", isAdminAfter);
        
        if (!isAdminAfter) {
            console2.log("\nSuccessfully removed account from admin role.");
        } else {
            console2.log("\nFailed to remove account from admin role.");
        }
    }
}

/**
 * @title AddSystem
 * @notice Script to add an address to the system role
 * @dev This requires a private key with owner permissions
 */
contract AddSystem is Script {
    function run(address tokenAddress, address account) external {
        Token token = Token(tokenAddress);
        
        // Check current state
        bool isSystemBefore = token.isSystemAccount(account);
        
        console2.log("Contract address:", tokenAddress);
        console2.log("Account to add as system account:", account);
        console2.log("Is already system account:", isSystemBefore);
        
        // Skip if already a system account
        if (isSystemBefore) {
            console2.log("\nAccount is already a system account. No action needed.");
            return;
        }
        
        console2.log("\nAdding account as system account...");
        
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Add system account
        token.addSystemAccount(account);
        
        // End broadcasting
        vm.stopBroadcast();
        
        // Verify the change
        bool isSystemAfter = token.isSystemAccount(account);
        console2.log("\nAfter update:");
        console2.log("Is system account now:", isSystemAfter);
        
        if (isSystemAfter) {
            console2.log("\nSuccessfully added account as system account.");
        } else {
            console2.log("\nFailed to add account as system account.");
        }
    }
}

/**
 * @title RemoveSystem
 * @notice Script to remove an address from the system role
 * @dev This requires a private key with owner permissions
 */
contract RemoveSystem is Script {
    function run(address tokenAddress, address account) external {
        Token token = Token(tokenAddress);
        
        // Check current state
        bool isSystemBefore = token.isSystemAccount(account);
        
        console2.log("Contract address:", tokenAddress);
        console2.log("Account to remove from system role:", account);
        console2.log("Is system account:", isSystemBefore);
        
        // Skip if not a system account
        if (!isSystemBefore) {
            console2.log("\nAccount is not a system account. No action needed.");
            return;
        }
        
        console2.log("\nRemoving account from system role...");
        
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Remove system account
        token.removeSystemAccount(account);
        
        // End broadcasting
        vm.stopBroadcast();
        
        // Verify the change
        bool isSystemAfter = token.isSystemAccount(account);
        console2.log("\nAfter update:");
        console2.log("Is system account now:", isSystemAfter);
        
        if (!isSystemAfter) {
            console2.log("\nSuccessfully removed account from system role.");
        } else {
            console2.log("\nFailed to remove account from system role.");
        }
    }
}

/**
 * @title GetValidator
 * @notice Script to get the current validator address
 * @dev This is a read-only script
 */
contract GetValidator is Script {
    function run(address tokenAddress) external view {
        Token token = Token(tokenAddress);
        
        address validator = address(token.validator());
        
        console2.log("Contract address:", tokenAddress);
        console2.log("Current validator:", validator);
    }
}

/**
 * @title SetValidator
 * @notice Script to set a new validator address
 * @dev This requires a private key with owner permissions
 */
contract SetValidator is Script {
    function run(address tokenAddress, address validatorAddress) external {
        Token token = Token(tokenAddress);
        
        // Check current state
        address validatorBefore = address(token.validator());
        
        console2.log("Contract address:", tokenAddress);
        console2.log("Current validator:", validatorBefore);
        console2.log("New validator:", validatorAddress);
        
        // Skip if already the correct validator
        if (validatorBefore == validatorAddress) {
            console2.log("\nValidator is already set to this address. No action needed.");
            return;
        }
        
        console2.log("\nSetting new validator...");
        
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Set validator
        token.setValidator(validatorAddress);
        
        // End broadcasting
        vm.stopBroadcast();
        
        // Verify the change
        address validatorAfter = address(token.validator());
        console2.log("\nAfter update:");
        console2.log("New validator:", validatorAfter);
        
        if (validatorAfter == validatorAddress) {
            console2.log("\nSuccessfully set new validator.");
        } else {
            console2.log("\nFailed to set new validator.");
        }
    }
}
