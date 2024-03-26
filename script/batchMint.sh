#!/bin/bash

# Check if all arguments are provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <tokenAddress> "
    exit 1
fi

echo "sourcing local env."
source .env.local
export PRIVATE_KEY=$PRIVATE_KEY

# Assign arguments to variables
tokenAddress=$1


# Export the variables as environment variables
export TOKEN_ADDRESS=$tokenAddress

# Call the Forge script
echo "configure tokens"
forge script script/batchMint.s.sol --rpc-url $RPC_URL --broadcast


