#!/bin/bash

# Check if all arguments are provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <RPC> <tokenAddress> <targetAddress> <amount>"
    exit 1
fi

echo "sourcing local env."
source .env.local
export PRIVATE_KEY=$PRIVATE_KEY

# Assign arguments to variables
rpc=$1
tokenAddress=$2
targetAddress=$3
amount=$4

# Export the variables as environment variables
export TOKEN=$tokenAddress
export TARGET=$targetAddress
export AMOUNT=$amount

# Call the Forge script
echo "mint token"
forge script script/mint.s.sol --rpc-url $rpc --broadcast --legacy


