#!/bin/bash

# Source environment variables
echo "sourcing local env."
source .env.local
export PRIVATE_KEY=$PRIVATE_KEY
# Run validation
echo "Running validation..."
npm run validate

# Initialize verifier URL variable
VERIFIER_URL=""

# Check if a flag is set
if [ "$1" == "--arbitrum-sepolia" ]; then
    echo "Deploying to Arbitrum Sepolia..."
    RPC_URL=$ARBITRUM_SEPOLIA_RPC
    ETHERSCAN_API_KEY=$ARBISCAN_API_KEY
    VERIFIER_URL="--verifier-url $ARBISCAN_URL --chain-id $ARBITRUM_SEPOLIA_CHAIN_ID"
elif [ "$1" == "--opt-sepolia" ]; then
    echo "Deploying to Optimistic Sepolia..."
    RPC_URL=$OPT_SEPOLIA_RPC
    ETHERSCAN_API_KEY=$OPTSCAN_API_KEY
    VERIFIER_URL="--verifier-url $OPTSCAN_URL --chain-id $OPT_SEPOLIA_CHAIN_ID"
elif [ "$1" == "--avalanche-fuji" ]; then
    echo "Deploying to Avalanche Fuji..."
    RPC_URL=$AVALANCHE_FUJI_RPC
    ETHERSCAN_API_KEY=$SNOWTRACE_API_KEY
    VERIFIER_URL="--verifier-url $SNOWTRACE_URL --chain-id $AVALANCHE_FUJI_CHAIN_ID"
fi

# Deploying all tokens
echo "Deploying all tokens..."
forge script script/deploy.s.sol:EUR --rpc-url $RPC_URL --broadcast --etherscan-api-key $ETHERSCAN_API_KEY --verify $VERIFIER_URL -vvvv


echo "Deployment process completed."
