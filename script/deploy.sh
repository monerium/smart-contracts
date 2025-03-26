#!/bin/bash
# deploy.sh - Core deployment script

# Function to handle deployment
deploy() {
  local network="$1"
  local contract="$2"
  local gas_limit="$3"
  local verify="$4"
  local legacy="$5"
  local verbosity="$6"
  local skip_confirm="$7"

  # Default values
  gas_limit=${gas_limit:-"8000000"}
  legacy=${legacy:-"--legacy"}
  verify=${verify:-"true"}
  verbosity=${verbosity:-"v"}

  # Get network-specific RPC URL
  local upper_network=$(echo "$network" | tr '[:lower:]' '[:upper:]')
  local rpc_var="${upper_network}_RPC"

  # Determine contract adjustments based on network
  if [ -z "$contract" ] || [ "$contract" = "All" ]; then
    # Gnosis networks
    if [ "$network" = "gnosis" ] || [ "$network" = "gnosis-chiado" ]; then
      contract="AllControllerGnosis"
      echo "Using Gnosis controller for this network"
    # Polygon networks
    elif [ "$network" = "polygon" ] || [ "$network" = "polygon-amoy" ]; then
      contract="AllControllerPolygon"
      echo "Using Polygon controller for this network"
    # Local development
    elif [ "$network" = "localhost" ]; then
      verify="false"
    else
      contract="All"
    fi
  fi

  # Confirmation prompt
  if [ "$skip_confirm" != "true" ]; then
    echo -e "\n⚠️  WARNING: You are about to deploy:"
    echo -n "   ▸ Address          : "
    node script/ethers-log-address.js
    echo "   ▸ Contract         : $contract"
    echo "   ▸ Network          : $network"
    echo "   ▸ RPC URL          : ${!rpc_var}"
    echo "   ▸ Gas Limit        : $gas_limit"
    echo "   ▸ Legacy Tx Format : $legacy"
    echo "   ▸ Verify Contract  : $verify"
    echo "   ▸ Verbosity Level  : $verbosity"

    echo -e "\nContinue? (y/N): "
    read -r response
    if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
      echo "Operation cancelled."
      exit 1
    fi
    echo "Proceeding with deployment..."
  fi

  # Execute deployment
  # Accessing the RPC URL indirectly through the variable name
  local rpc_url=${!rpc_var}

  if [ -z "$rpc_url" ]; then
    echo "❌ Error: RPC URL for $network not found"
    exit 1
  fi

  local verify_param=""
  if [ "$verify" = "true" ]; then
    verify_param="--verify"
  fi

  echo forge script script/deploy.s.sol:$contract \
    --rpc-url "$rpc_url" \
    --broadcast \
    $verify_param \
    --gas-limit "$gas_limit" \
    -$verbosity \
    $legacy

  exit 0
  forge script script/deploy.s.sol:$contract \
    --rpc-url "$rpc_url" \
    --broadcast \
    $verify_param \
    --gas-limit "$gas_limit" \
    -$verbosity \
    $legacy
}

# Function to validate testnet
validate_testnet() {
  local network="$1"

  # Validate that this is actually a testnet
  if [[ "$network" != *"sepolia"* && "$network" != *"fuji"* && "$network" != *"chiado"* && "$network" != *"amoy"* && "$network" != "localhost" ]]; then
    echo "⚠️ Warning: $network doesn't appear to be a testnet. Continue anyway? (y/N): "
    read -r response
    if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
      echo "Operation cancelled."
      exit 1
    fi
  fi
}

# Function to estimate gas
estimate_gas() {
  local network="$1"
  local contract="$2"
  local verbosity="$3"

  # Get network-specific RPC URL
  local rpc_var="${network^^}_RPC"
  local rpc_url=${!rpc_var}

  if [ -z "$rpc_url" ]; then
    echo "❌ Error: RPC URL for $network not found"
    exit 1
  fi

  echo "⛽ Estimating gas for deploying $contract to $network..."
  forge script script/deploy.s.sol:$contract \
    --rpc-url "$rpc_url" \
    -$verbosity \
    --gas-report
}

# Parse and execute command
if [ "$1" = "deploy" ]; then
  shift
  deploy "$@"
elif [ "$1" = "validate-testnet" ]; then
  shift
  validate_testnet "$@"
elif [ "$1" = "estimate-gas" ]; then
  shift
  estimate_gas "$@"
else
  echo "Unknown command: $1"
  echo "Available commands: deploy, validate-testnet, estimate-gas"
  exit 1
fi
