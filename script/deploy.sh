#!/bin/bash
# deploy.sh - Core deployment script with modular functions

# Function to determine the appropriate contract based on network
determine_contract() {
  local network="$1"
  local contract="$2"

  if [ -z "$contract" ] || [ "$contract" = "All" ]; then
    # Gnosis networks
    if [ "$network" = "gnosis" ] || [ "$network" = "gnosis-chiado" ]; then
      contract="AllControllerGnosis"
      echo "Using Gnosis controller for this network"
    # Polygon networks
    elif [ "$network" = "polygon" ] || [ "$network" = "polygon-amoy" ]; then
      contract="AllControllerPolygon"
      echo "Using Polygon controller for this network"
    else
      contract="All"
    fi
  fi

  echo "$contract"
}

# Function to get the RPC URL for a given network
get_rpc_url() {
  local network="$1"
  local upper_network=$(echo "$network" | tr '[:lower:]' '[:upper:]')
  local rpc_var="${upper_network}_RPC"
  local rpc_url=${!rpc_var}

  if [ -z "$rpc_url" ]; then
    echo "❌ Error: RPC URL for $network not found" >&2
    exit 1
  fi

  echo "$rpc_url"
}

# Function to generate verification parameters based on network
generate_verify_params() {
  local network="$1"

  # Skip verification for localhost
  if [ "$network" = "localhost" ]; then
    echo ""
    return 0
  fi

  # Special case for linea-sepolia
  if [ "$network" = "linea-sepolia" ]; then
    echo "--verify --slow --retries 4 --delay 5"
    return 0
  fi

  # Load network configuration
  if [ ! -f "./networks.yml" ]; then
    echo "❌ Error: networks.yml file not found" >&2
    return 1
  fi

  # Function to extract values from yaml for a given network and key
  get_yaml_value() {
    local net=$1
    local key=$2
    grep -A10 "^  $net:" ./networks.yml | grep -m1 "^    $key:" | sed 's/.*: //'
  }

  # Extract network configuration
  local chain_id=$(get_yaml_value "$network" "chain_id")
  local verifier_url=$(get_yaml_value "$network" "verifier_url")
  local verifier_type=$(get_yaml_value "$network" "verifier_type")

  # If we couldn't find the network in the config, return error
  if [ -z "$chain_id" ]; then
    echo "❌ Error: Network $network not found in configuration" >&2
    return 1
  fi

  # Determine the API key environment variable name based on network
  local api_key_var=""

  case "$network" in
  arbitrum*) api_key_var="ARBISCAN_API_KEY" ;;
  optimism*) api_key_var="OPTISCAN_API_KEY" ;;
  avalanche*) api_key_var="SNOWTRACESCAN_API_KEY" ;;
  gnosis*) api_key_var="GNOSISSCAN_API_KEY" ;;
  polygon*) api_key_var="POLYGONSCAN_API_KEY" ;;
  linea*) api_key_var="LINEASCAN_API_KEY" ;;
  scroll*) api_key_var="SCROLLSCAN_API_KEY" ;;
  camino*) api_key_var="CAMINO_API_KEY" ;;
  *) api_key_var="ETHERSCAN_API_KEY" ;; # Default for Ethereum networks
  esac

  # Get the API key value
  local api_key=${!api_key_var}

  if [ -z "$api_key" ]; then
    echo "⚠️ Warning: API key for $network ($api_key_var) not found" >&2
  fi

  # Build the verification parameters based on verifier type
  local verify_params="--etherscan-api-key $api_key --verify"

  if [ "$verifier_type" = "blockscout" ]; then
    verify_params="$verify_params --verifier blockscout"
  fi

  verify_params="$verify_params --verifier-url $verifier_url --chain-id $chain_id"

  echo "$verify_params"
}

# Function to display deployment configuration and prompt for confirmation
confirm_deployment() {
  local network="$1"
  local contract="$2"
  local gas_limit="$3"
  local legacy="$4"
  local verify="$5"
  local verbosity="$6"
  local skip_confirm="$7"
  local rpc_url="$8"

  if [ "$skip_confirm" != "true" ]; then
    echo -e "\n⚠️  WARNING: You are about to deploy:"
    echo -n "   ▸ Address          : "
    node script/ethers-log-address.js
    echo "   ▸ Contract         : $contract"
    echo "   ▸ Network          : $network"
    echo "   ▸ RPC URL          : $rpc_url"
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

  return 0
}

# Function to prepare deployment parameters
prepare_deployment_params() {
  local verify="$1"
  local network="$2"

  local verify_param=""
  if [ "$verify" = "true" ]; then
    verify_param=$(generate_verify_params "$network")
  fi

  echo "$verify_param"
}

# Function to execute the forge deployment command
execute_deployment() {
  local contract="$1"
  local rpc_url="$2"
  local verify_param="$3"
  local gas_limit="$4"
  local verbosity="$5"
  local legacy="$6"

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

# Main deployment function that uses the helper functions
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

  # Determine appropriate contract
  contract=$(determine_contract "$network" "$contract")

  # Get RPC URL for the network
  rpc_url=$(get_rpc_url "$network")

  # Confirm deployment
  confirm_deployment "$network" "$contract" "$gas_limit" "$legacy" "$verify" "$verbosity" "$skip_confirm" "$rpc_url"

  # Prepare deployment parameters (now passing network parameter)
  verify_param=$(prepare_deployment_params "$verify" "$network")

  # Execute deployment
  execute_deployment "$contract" "$rpc_url" "$verify_param" "$gas_limit" "$verbosity" "$legacy"

  exit 0
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
  rpc_url=$(get_rpc_url "$network")

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
