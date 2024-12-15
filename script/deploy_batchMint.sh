source .env.local

echo $PRIVATE_KEY
forge create --contracts src/BatchMint.sol --private-key $PRIVATE_KEY --etherscan-api-key $ETHERSCAN_API_KEY --verify --rpc-url $RPC_URL BatchMint
