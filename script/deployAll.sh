#!/bin/bash

# Source environment variables
echo "sourcing local env."
source .env.local
export PRIVATE_KEY=$PRIVATE_KEY

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
elif [ "$1" == "--gnosis-chiado" ]; then
  echo "Deploying to Gnosis Chiado..."
  RPC_URL=$GNOSIS_CHIADO_RPC
  VERIFIER_URL="--verifier blockscout --verifier-url $GNOSIS_CHIADO_BLOCKSCOUT_URL --chain-id $GNOSIS_CHIADO_CHAIN_ID"
  echo $VERIFIER_URL
  forge script script/deploy.s.sol:AllControllerGnosis --rpc-url $RPC_URL --broadcast --verify $VERIFIER_URL -vvvv --legacy
  exit 0
elif [ "$1" == "--gnosis" ]; then
  echo "Deploying to Gnosis..."
  RPC_URL=$GNOSIS_RPC
  ETHERSCAN_API_KEY=$GNOSISSCAN_API
  VERIFIER_URL="--verifier-url $GNOSISSCAN_URL --chain-id $GNOSIS_CHAIN_ID"
  echo $VERIFIER_URL
  forge script script/deploy.s.sol:AllControllerGnosis --rpc-url $RPC_URL --broadcast --etherscan-api-key $ETHERSCAN_API_KEY --verify $VERIFIER_URL -vvvv --legacy
  exit 0
elif [ "$1" == "--polygon-amoy" ]; then
  echo "Deploying to Polygon Amoy..."
  RPC_URL=$POLYGON_AMOY_RPC
  ETHERSCAN_API_KEY=$POLYGONSCAN_API
  VERIFIER_URL="--verifier-url $POLYGONSCAN_AMOY_URL --chain-id $POLYGON_AMOY_CHAIN_ID"
  echo $VERIFIER_URL
  forge script script/deploy.s.sol:AllControllerPolygon --rpc-url $RPC_URL --broadcast --etherscan-api-key $ETHERSCAN_API_KEY --verify $VERIFIER_URL -vvvv --legacy
  exit 0
elif [ "$1" == "--polygon" ]; then
  echo "Deploying to Polygon..."
  RPC_URL=$POLYGON_RPC
  ETHERSCAN_API_KEY=$POLYGONSCAN_API
  VERIFIER_URL="--verifier-url $POLYGONSCAN_URL --chain-id $POLYGON_CHAIN_ID"
  echo $VERIFIER_URL
  forge script script/deploy.s.sol:AllControllerPolygon --rpc-url $RPC_URL --broadcast --etherscan-api-key $ETHERSCAN_API_KEY --verify $VERIFIER_URL -vvvv --legacy
  exit 0
elif [ "$1" == "--linea-sepolia" ]; then
  echo "Deploying to Linea Sepolia..."
  RPC_URL=$LINEA_SEPOLIA_RPC
  ETHERSCAN_API_KEY=$LINEASCAN_API_KEY
  echo "$ETHERSCAN_API_KEY"

  forge script script/deploy.s.sol:All \
    --rpc-url $RPC_URL \
    --broadcast \
    --gas-limit 8000000 \
    --delay 5 \
    --retries 4 \
    --slow \
    --verify \
    -vvvv \
    --legacy
  exit 0
elif [ "$1" == "--camino-columbus" ]; then
  echo "Deploying to Camino Columbus..."
  RPC_URL=$CAMINO_COLUMBUS_RPC
  PRIVATE_KEY=$CAMINO_COLUMBUS_PRIVATE_KEY
  VERIFIER_URL="--verifier blockscout --verifier-url $CAMINOSCAN_COLUMBUS_URL --chain-id $CAMINO_COLUMBUS_CHAIN_ID"
  echo $VERIFIER_URL
  # Note: Since Camino Columbus uses a different private key format, we need to handle it specially
  forge script script/deploy.s.sol:All \
    --rpc-url $RPC_URL \
    --broadcast \
    --gas-limit 8000000 \
    --verify \
    $VERIFIER_URL \
    -vvvv \
    --legacy
  exit 0
fi

# Deploying all tokens
echo "Deploying all tokens..."
forge script script/deploy.s.sol:EUR --rpc-url $RPC_URL --broadcast -vvvv --etherscan-api-key $ETHERSCAN_API_KEY --verify $VERIFIER_URL -vvvv --legacy

echo "Deployment process completed."
