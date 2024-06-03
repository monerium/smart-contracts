#!/bin/bash

# Check if all arguments are provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <tokenAddress> <system> <admin> <allowance>"
    exit 1
fi

echo "sourcing local env."
source .env.local
export PRIVATE_KEY=$PRIVATE_KEY

# Assign arguments to variables
tokenAddress=$1
system=$2
admin=$3
allowance=$4


# Export the variables as environment variables
export TOKEN_ADDRESS=$tokenAddress
export SYSTEM_ADDRESS=$system
export ADMIN_ADDRESS=$admin
export MAX_MINT_ALLOWANCE=$allowance

# Call the Forge script
echo "configure tokens"
forge script script/configureToken.s.sol --rpc-url $RPC_URL --broadcast --etherscan-api-key $ETHERSCAN_API_KEY --legacy


