#!/bin/bash

setup_network() {
    if [ "$1" == "--arbitrum-sepolia" ]; then
        echo "Deploying to Arbitrum Sepolia..."
        export RPC_URL=$ARBITRUM_SEPOLIA_RPC
        export ETHERSCAN_API_KEY=$ARBISCAN_API_KEY
        export VERIFIER_URL="--verifier-url $ARBISCAN_URL --chain-id $ARBITRUM_SEPOLIA_CHAIN_ID"
    elif [ "$1" == "--opt-sepolia" ]; then
        echo "Deploying to Optimistic Sepolia..."
        export RPC_URL=$OPT_SEPOLIA_RPC
        export ETHERSCAN_API_KEY=$OPTSCAN_API_KEY
        export VERIFIER_URL="--verifier-url $OPTSCAN_URL --chain-id $OPT_SEPOLIA_CHAIN_ID"
    elif [ "$1" == "--avalanche-fuji" ]; then
        echo "Deploying to Avalanche Fuji..."
        export RPC_URL=$AVALANCHE_FUJI_RPC
        export ETHERSCAN_API_KEY=$SNOWTRACE_API_KEY
        export VERIFIER_URL="--verifier-url $SNOWTRACE_URL --chain-id $AVALANCHE_FUJI_CHAIN_ID"
    fi
}
