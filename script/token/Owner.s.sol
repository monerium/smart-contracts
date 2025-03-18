// SPDX-License-Identifier: APACHE 2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import "../../src/Token.sol";

/**
 * @title Owner
 * @notice Script to check the current owner of a token contract
 * @dev This is a read-only script
 */
contract Owner is Script {
    function run(address tokenAddress) external view {
        Token token = Token(tokenAddress);
        
        // Get and display owner information
        address currentOwner = token.owner();
        
        console2.log("Contract address:", tokenAddress);
        console2.log("Current owner:", currentOwner);
    }
}

/**
 * @title PendingOwner
 * @notice Script to check the pending owner of a token contract
 * @dev This is a read-only script
 */
contract PendingOwner is Script {
    function run(address tokenAddress) external view {
        Token token = Token(tokenAddress);
        
        // Get and display pending owner information
        address pendingOwner = token.pendingOwner();
        
        console2.log("Contract address:", tokenAddress);
        console2.log("Pending owner:", pendingOwner);
    }
}

/**
 * @title OwnershipInfo
 * @notice Script to check both current and pending owner of a token contract
 * @dev This is a read-only script
 */
contract OwnershipInfo is Script {
    function run(address tokenAddress) external view {
        Token token = Token(tokenAddress);
        
        // Get and display ownership information
        address currentOwner = token.owner();
        address pendingOwner = token.pendingOwner();
        
        console2.log("Contract address:", tokenAddress);
        console2.log("Current owner:", currentOwner);
        console2.log("Pending owner:", pendingOwner);
    }
}

/**
 * @title TransferOwnership
 * @notice Script to transfer ownership of a token contract
 * @dev This requires a private key with owner permissions
 */
contract TransferOwnership is Script {
    function run(address tokenAddress, address newOwner) external {
        Token token = Token(tokenAddress);
        
        // Log the information before the transfer
        console2.log("Contract address:", tokenAddress);
        console2.log("Current owner:", token.owner());
        console2.log("Pending owner:", token.pendingOwner());
        
        console2.log("\nTransferring ownership to:", newOwner);
        
        // Start the broadcast with the private key from environment
        vm.startBroadcast();
        
        // Transfer ownership
        token.transferOwnership(newOwner);
        
        // End the broadcast
        vm.stopBroadcast();
        
        // Log the information after the transfer
        console2.log("\nAfter transfer:");
        console2.log("Current owner:", token.owner());
        console2.log("Pending owner:", token.pendingOwner());
        console2.log("\nOwnership transfer initiated. New owner must accept ownership.");
    }
}

/**
 * @title AcceptOwnership
 * @notice Script to accept ownership of a token contract
 * @dev This requires a private key with pending owner permissions
 */
contract AcceptOwnership is Script {
    function run(address tokenAddress) external {
        Token token = Token(tokenAddress);
        
        // Log the information before accepting
        console2.log("Contract address:", tokenAddress);
        console2.log("Current owner:", token.owner());
        console2.log("Pending owner:", token.pendingOwner());
        
        console2.log("\nAccepting ownership...");
        
        // Start the broadcast with the private key from environment
        vm.startBroadcast();
        
        // Accept ownership
        token.acceptOwnership();
        
        // End the broadcast
        vm.stopBroadcast();
        
        // Log the information after accepting
        console2.log("\nAfter accepting:");
        console2.log("Current owner:", token.owner());
        console2.log("Pending owner:", token.pendingOwner());
        console2.log("\nOwnership successfully accepted.");
    }
}
