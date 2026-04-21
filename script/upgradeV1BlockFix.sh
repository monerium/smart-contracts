#!/bin/bash
# Upgrade script for the V1Block fix on Ethereum, Gnosis, and Polygon.
#
# The proxy owner is a Gnosis Safe, so we split the work:
#   Step 1 (this script, any funded EOA):
#     - Deploy new Validator
#     - Deploy new ControllerToken implementation
#   Step 2 (Safe, after step 1):
#     - This script prints the calldata for the Safe Transaction Builder.
#     - For each proxy: upgradeToAndCall + setValidator (batch in one Safe tx per proxy).
#
# Usage:
#   source .env.local
#   sh script/upgradeV1BlockFix.sh --gnosis-chiado   # testnet
#   sh script/upgradeV1BlockFix.sh --polygon-amoy    # testnet
#   sh script/upgradeV1BlockFix.sh --sepolia          # testnet
#   sh script/upgradeV1BlockFix.sh --gnosis           # mainnet
#   sh script/upgradeV1BlockFix.sh --polygon          # mainnet
#   sh script/upgradeV1BlockFix.sh --ethereum         # mainnet
#
# Required env vars:
#   PRIVATE_KEY        - any funded EOA for deploying contracts
#   VALIDATOR_ADMIN    - address that will receive ADMIN_ROLE on the new Validator
#   PROXY_EUR / PROXY_USD / PROXY_GBP / PROXY_ISK  - proxy addresses on the target chain

set -e

NETWORK_FLAG="$1"

# ── network configuration ──────────────────────────────────────────────────────

if [ "$NETWORK_FLAG" == "--gnosis-chiado" ]; then
    echo "Network: Gnosis Chiado (testnet)"
    RPC_URL=$GNOSIS_CHIADO_RPC
    IMPL_CONTRACT="DeployImplGnosis"
    FORGE_FLAGS="--legacy --verify --verifier blockscout --verifier-url $GNOSIS_CHIADO_BLOCKSCOUT_URL --chain-id $GNOSIS_CHIADO_CHAIN_ID"

elif [ "$NETWORK_FLAG" == "--gnosis" ]; then
    echo "Network: Gnosis mainnet"
    RPC_URL=$GNOSIS_RPC
    IMPL_CONTRACT="DeployImplGnosis"
    FORGE_FLAGS="--legacy --verify --etherscan-api-key $GNOSISSCAN_API --verifier-url $GNOSISSCAN_URL --chain-id $GNOSIS_CHAIN_ID"

elif [ "$NETWORK_FLAG" == "--polygon-amoy" ]; then
    echo "Network: Polygon Amoy (testnet)"
    RPC_URL=$POLYGON_AMOY_RPC
    IMPL_CONTRACT="DeployImplPolygon"
    FORGE_FLAGS="--legacy --verify --etherscan-api-key $POLYGONSCAN_API --verifier-url $POLYGONSCAN_AMOY_URL --chain-id $POLYGON_AMOY_CHAIN_ID"

elif [ "$NETWORK_FLAG" == "--polygon" ]; then
    echo "Network: Polygon mainnet"
    RPC_URL=$POLYGON_RPC
    IMPL_CONTRACT="DeployImplPolygon"
    FORGE_FLAGS="--legacy --verify --etherscan-api-key $POLYGONSCAN_API --verifier-url $POLYGONSCAN_URL --chain-id $POLYGON_CHAIN_ID"

elif [ "$NETWORK_FLAG" == "--sepolia" ]; then
    echo "Network: Sepolia (testnet)"
    RPC_URL=$SEPOLIA_RPC
    IMPL_CONTRACT="DeployImplEthereum"
    FORGE_FLAGS="--verify --etherscan-api-key $ETHERSCAN_API_KEY"

elif [ "$NETWORK_FLAG" == "--ethereum" ]; then
    echo "Network: Ethereum mainnet"
    RPC_URL=$ETHEREUM_RPC
    IMPL_CONTRACT="DeployImplEthereum"
    FORGE_FLAGS="--verify --etherscan-api-key $ETHERSCAN_API_KEY"

else
    echo "Usage: sh script/upgradeV1BlockFix.sh <network>"
    echo "  --gnosis-chiado   Gnosis Chiado testnet"
    echo "  --polygon-amoy    Polygon Amoy testnet"
    echo "  --sepolia         Ethereum Sepolia testnet"
    echo "  --gnosis          Gnosis mainnet"
    echo "  --polygon         Polygon mainnet"
    echo "  --ethereum        Ethereum mainnet"
    exit 1
fi

# ── validate required env vars ─────────────────────────────────────────────────

: "${PRIVATE_KEY:?PRIVATE_KEY is required}"
: "${VALIDATOR_ADMIN:?VALIDATOR_ADMIN is required}"
: "${PROXY_EUR:?PROXY_EUR is required}"
: "${PROXY_USD:?PROXY_USD is required}"
: "${PROXY_GBP:?PROXY_GBP is required}"
: "${PROXY_ISK:?PROXY_ISK is required}"

# ── step 1a: deploy new Validator ─────────────────────────────────────────────

echo ""
echo "=== Step 1a: Deploy new Validator ==="
VALIDATOR_OUTPUT=$(forge script script/UpgradeV1BlockFix.s.sol:DeployValidator \
    --rpc-url "$RPC_URL" \
    --broadcast \
    $FORGE_FLAGS \
    -vvvv 2>&1)

echo "$VALIDATOR_OUTPUT"

VALIDATOR=$(echo "$VALIDATOR_OUTPUT" | grep "New Validator:" | awk '{print $NF}')
if [ -z "$VALIDATOR" ]; then
    echo "ERROR: Could not extract Validator address. Set VALIDATOR=<addr> manually."
    exit 1
fi
echo "Validator: $VALIDATOR"

# ── step 1b: deploy new implementation ────────────────────────────────────────

echo ""
echo "=== Step 1b: Deploy new ControllerToken implementation ==="
IMPL_OUTPUT=$(forge script "script/UpgradeV1BlockFix.s.sol:$IMPL_CONTRACT" \
    --rpc-url "$RPC_URL" \
    --broadcast \
    $FORGE_FLAGS \
    -vvvv 2>&1)

echo "$IMPL_OUTPUT"

IMPL=$(echo "$IMPL_OUTPUT" | grep -E "New .+ControllerToken impl:" | awk '{print $NF}')
if [ -z "$IMPL" ]; then
    echo "ERROR: Could not extract implementation address. Set IMPL=<addr> manually."
    exit 1
fi
echo "Implementation: $IMPL"

# ── step 2: print Safe calldata for each proxy ────────────────────────────────

print_calldata() {
    local label="$1"
    local proxy_addr="$2"

    echo ""
    echo "=== Step 2: Safe calldata for $label proxy ==="
    PROXY="$proxy_addr" IMPL="$IMPL" VALIDATOR="$VALIDATOR" \
        forge script script/UpgradeV1BlockFix.s.sol:PrintSafeCalldata \
        --rpc-url "$RPC_URL" \
        -vvvv 2>&1 | grep -A 20 "=== Safe transactions"
}

print_calldata "EUR" "$PROXY_EUR"
print_calldata "USD" "$PROXY_USD"
print_calldata "GBP" "$PROXY_GBP"
print_calldata "ISK" "$PROXY_ISK"

echo ""
echo "=== Summary ==="
echo "New Validator  : $VALIDATOR"
echo "New Impl       : $IMPL"
echo ""
echo "Next: submit the Safe transactions above via the Safe Transaction Builder."
echo "Batch upgradeToAndCall + setValidator into a single Safe tx per proxy."
