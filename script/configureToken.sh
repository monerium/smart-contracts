#!/bin/bash

# Check if all arguments are provided
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <RPC> <tokenAddress> <system> <admin> <allowance>"
    exit 1
fi

echo "sourcing local env."
source .env.local
export PRIVATE_KEY=$PRIVATE_KEY

# Assign arguments to variables
rpc=$1
tokenAddress=$2
system=$3
admin=$4
allowance=$5


# Export the variables as environment variables
export TOKEN_ADDRESS=$tokenAddress
export SYSTEM_ADDRESS=$system
export ADMIN_ADDRESS=$admin
export LIMIT_CAP=$allowance


# Call the Forge script
echo "configure tokens"
forge script script/configureToken.s.sol --rpc-url $rpc --broadcast --etherscan-api-key $ETHERSCAN_API_KEY --legacy


