// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import "../src/Token.sol";

/**
 * @title Ownership
 * @notice Script to manage ownership operations for the stablecoin contract
 * @dev This script provides functionality to:
 *      - Transfer ownership to a new address
 *      - Accept ownership (for a pending owner)
 *      - Check the current pending owner
 *
 * @dev HOW TO USE DIRECTLY FROM COMMAND LINE:
 * 
 * 1. To check pending owner:
 *    forge script script/Ownership.s.sol:CheckPending \
 *      --rpc-url $RPC_URL \
 *      -vvv \
 *      --sig "run(address)" <CONTRACT_ADDRESS>
 *
 * 2. To transfer ownership:
 *    forge script script/Ownership.s.sol:Transfer \
 *      --rpc-url $RPC_URL \
 *      --broadcast \
 *      --private-key $PRIVATE_KEY \
 *      -vvv \
 *      --sig "run(address,address)" <CONTRACT_ADDRESS> <NEW_OWNER_ADDRESS>
 *
 * 3. To accept ownership:
 *    forge script script/Ownership.s.sol:Accept \
 *      --rpc-url $RPC_URL \
 *      --broadcast \
 *      --private-key $PRIVATE_KEY \
 *      -vvv \
 *      --sig "run(address)" <CONTRACT_ADDRESS>
 */

/**
 * @notice Base script with common functionality
 */
abstract contract BaseScript is Script {
    /**
     * @notice Log contract ownership information
     * @param contractAddress Address of the stablecoin contract
     */
    function logContractInfo(address contractAddress) internal view {
        Token token = Token(contractAddress);
        
        address currentOwner = token.owner();
        address pendingOwner = token.pendingOwner();
        
        console2.log("Contract address:", contractAddress);
        console2.log("Current owner:", currentOwner);
        console2.log("Pending owner:", pendingOwner);
    }
}

/**
 * @notice Script to check the pending owner of the contract
 * @dev Read-only script, doesn't require a private key
 */
contract CheckPending is BaseScript {
    /**
     * @notice Run the script to check pending owner
     * @param contractAddress Address of the stablecoin contract
     */
    function run(address contractAddress) external view {
        logContractInfo(contractAddress);
    }
}

/**
 * @notice Script to transfer ownership of the contract
 * @dev Requires private key of current owner to execute
 */
contract Transfer is BaseScript {
    /**
     * @notice Run the script to transfer ownership
     * @param contractAddress Address of the stablecoin contract
     * @param newOwner Address of the new owner
     */
    function run(address contractAddress, address newOwner) external {
        // Log the information before the transfer
        console2.log("--- Before transfer ---");
        logContractInfo(contractAddress);
        
        console2.log("\nTransferring ownership to:", newOwner);
        
        // Start the broadcast with the private key from environment
        vm.startBroadcast();
        
        // Transfer ownership - direct call to the contract
        Token token = Token(contractAddress);
        token.transferOwnership(newOwner);
        
        // End the broadcast
        vm.stopBroadcast();
        
        // Log the information after the transfer
        console2.log("\n--- After transfer ---");
        logContractInfo(contractAddress);
        console2.log("\nOwnership transfer initiated. New owner must accept ownership.");
    }
}

/**
 * @notice Script to accept ownership of the contract
 * @dev Requires private key of pending owner to execute
 */
contract Accept is BaseScript {
    /**
     * @notice Run the script to accept ownership
     * @param contractAddress Address of the stablecoin contract
     */
    function run(address contractAddress) external {
        // Log the information before accepting
        console2.log("--- Before accepting ownership ---");
        logContractInfo(contractAddress);
        
        // Start the broadcast with the private key from environment
        vm.startBroadcast();
        
        // Accept ownership - direct call to the contract
        Token token = Token(contractAddress);
        token.acceptOwnership();
        
        // End the broadcast
        vm.stopBroadcast();
        
        // Log the information after accepting
        console2.log("\n--- After accepting ownership ---");
        logContractInfo(contractAddress);
        console2.log("\nOwnership successfully accepted.");
    }
}
