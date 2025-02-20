#!/bin/bash
# Check if minimum arguments are provided (at least 4: RPC, tokenAddress, system, allowance)
if [ "$#" -lt 4 ]; then
  echo "Usage: $0 <RPC> <tokenAddress> <maxAllowance> <allowancePerSystem> <system> <admin1> [admin2] [admin3] ..."
  exit 1
fi

# Assign fixed arguments to variables
rpc="$1"
tokenAddress="$2"
maxAllowance="$3"
allowance="$4"
system="$5"

# Remove the first 4 arguments to leave only admin addresses
shift 4

# Export the fixed variables
export TOKEN_ADDRESS="$tokenAddress"
export SYSTEM_ADDRESS="$system"
export MAX_MINT_ALLOWANCE="$maxAllowance"
export MINT_ALLOWANCE="$allowance"

# Export the number of admins
export ADMIN_COUNT=$#

# Export each admin address with an index
index=0
for admin in "$@"; do
  export "ADMIN_ADDRESS_$index=$admin"
  echo "Configured admin $index: $admin"
  index=$((index + 1))
done

# Call the Forge script
echo "configure tokens"
forge script script/configureToken.s.sol:All --rpc-url "$rpc" --broadcast --legacy -vvvv
