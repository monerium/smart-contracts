package main

import (
	"context"
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"math/big"
	"os"
	"path/filepath"
	"sort"
	//	"strings"

	"github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/crypto"

	"github.com/ethereum/go-ethereum/ethclient"
	"google.golang.org/protobuf/proto"
)

const queryStep = 400000

// const queryStep = 20000
var erc20ABI = `[{
	"constant": true,
	"inputs": [{"name": "_owner", "type": "address"}],
	"name": "balanceOf", "outputs": [{"name": "balance", "type": "uint256"}],
	"payable": false,
	"stateMutability": "view",
	"type": "function"
}, {
	"constant": true,
	"inputs": [],
	"name": "totalSupply",
	"outputs": [{"name": "", "type": "uint256"}],
	"payable": false,
	"stateMutability": "view",
	"type": "function"
}, {
	"anonymous": false,
	"inputs": [{
		"indexed": true,
		"name": "from",
		"type": "address"
	}, {
		"indexed": true,
		"name": "to",
		"type": "address"
	}, {
		"indexed": false,
		"name": "value",
		"type": "uint256"
	}],
	"name": "Transfer",
	"type": "event"
}]`

func main() {
	if len(os.Args) < 5 {
		fmt.Println(len(os.Args))
		fmt.Println(os.Args)

		log.Fatalf("Usage: %s <rpcURL> <V2Address> <startBlock> <V1Address>", os.Args[0])
	}

	rpcURL := os.Args[1]
	v2Address := os.Args[2]
	startBlock := new(big.Int)
	startBlock.SetString(os.Args[3], 10)
	v1Address := common.HexToAddress(os.Args[4])

	client, err := ethclient.Dial(rpcURL)
	if err != nil {
		log.Fatalf("Failed to connect to the Ethereum client: %v", err)
	}
	/*
			contractABI, err := abi.JSON(strings.NewReader(erc20ABI))
			if err != nil {
				log.Fatalf("Failed to parse contract ABI: %v", err)
			}
		latestBlock, err := client.BlockNumber(context.Background())
		if err != nil {
			log.Fatalf("Failed to get the latest block number: %v", err)
		}

		holdersSet, err := fetchTokenHolders(client, contractABI, v1Address, startBlock, big.NewInt(int64(latestBlock)))
		if err != nil {
			log.Fatalf("Failed to fetch token holders: %v", err)
		}
		totalSum := TotalSumOfHoldersSet(holdersSet)
		fmt.Printf("Total sum of holders: %s\n", totalSum.String())
		fmt.Printf("Number of holders: %d\n", len(holdersSet))
		totalSupply, err := fetchTokenSupply(client, contractABI, v1Address)
		if err != nil {
			log.Fatalf("Failed to fetch token supply: %v", err)
		}

		fmt.Printf("Number of holders with balances > 0: %d\n", len(holdersSet))
		fmt.Printf(
			"Total sum vs total supply: %s == %s == %v\n",
			totalSum.String(),
			totalSupply.String(),
			totalSum.Cmp(totalSupply) == 0,
		)
	*/
	fakeHolders := DeriveAddresses([]byte("fakeTestKristenPirePourGnosis"), 14000)
	generateScript(client, fakeHolders, v2Address, v1Address.Hex())
}

// / For testing purpose

// DeriveAddresses generates n Ethereum addresses from a given seed
func DeriveAddresses(seed []byte, n int) map[common.Address]*big.Int {
	addressMap := make(map[common.Address]*big.Int)

	for i := 0; i < n; i++ {
		hash := sha256.New()
		hash.Write(seed)
		hash.Write([]byte(fmt.Sprintf("%d", i)))
		privateKeyBytes := hash.Sum(nil)
		privateKey, err := crypto.ToECDSA(privateKeyBytes)
		if err != nil {
			panic(err)
		}
		publicKey := privateKey.PublicKey
		address := crypto.PubkeyToAddress(publicKey)
		addressMap[address] = big.NewInt(1)
	}

	return addressMap
}

func fetchTokenSupply(client *ethclient.Client, contractABI abi.ABI, contractAddress common.Address) (*big.Int, error) {
	callData, err := contractABI.Pack("totalSupply")
	if err != nil {
		return nil, fmt.Errorf("failed to pack totalSupply call: %v", err)
	}

	msg := ethereum.CallMsg{
		To:   &contractAddress,
		Data: callData,
	}

	result, err := client.CallContract(context.Background(), msg, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to call contract: %v", err)
	}

	totalSupply := new(big.Int)
	totalSupply.SetBytes(result)
	return totalSupply, nil
}

// SaveHoldersSetToJSON saves the holdersSet to a JSON file with indentation
func SaveHoldersSetToJSON(holdersSet map[common.Address]*big.Int, fileName string) error {
	// Prepare the data for JSON encoding
	type Holder struct {
		Address string `json:"address"`
		Amount  string `json:"amount"`
	}

	var holdersSlice []Holder
	for addr, amount := range holdersSet {
		holdersSlice = append(holdersSlice, Holder{
			Address: addr.Hex(),
			Amount:  amount.String(),
		})
	}

	// Marshal the data to JSON with indentation
	jsonData, err := json.MarshalIndent(holdersSlice, "", "    ")
	if err != nil {
		return fmt.Errorf("failed to marshal holdersSet to JSON: %v", err)
	}

	// Write the JSON data to a file
	err = ioutil.WriteFile(fileName, jsonData, 0644)
	if err != nil {
		return fmt.Errorf("failed to write JSON data to file: %v", err)
	}

	return nil
}

// Load saved data from a file
func loadSavedData(contractAddress common.Address) (*SaveData, error) {
	filePath := fmt.Sprintf("./savedData/%s.dat", contractAddress.Hex())
	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		return nil, nil // No saved file
	}

	fileData, err := ioutil.ReadFile(filePath)
	if err != nil {
		return nil, fmt.Errorf("failed to read saved file: %v", err)
	}

	var data SaveData
	if err := proto.Unmarshal(fileData, &data); err != nil {
		return nil, fmt.Errorf("failed to unmarshal saved data: %v", err)
	}

	return &data, nil
}

// Save data to a file
func saveData(contractAddress common.Address, data *SaveData) error {
	filePath := fmt.Sprintf("./savedData/%s.dat", contractAddress.Hex())
	fileData, err := proto.Marshal(data)
	if err != nil {
		return fmt.Errorf("failed to marshal data: %v", err)
	}

	if err := ioutil.WriteFile(filePath, fileData, 0644); err != nil {
		return fmt.Errorf("failed to write file: %v", err)
	}

	return nil
}

// Prepare data to save
func prepareSaveData(holdersSet map[common.Address]*big.Int, currentBlock *big.Int) *SaveData {
	holdersSlice := make([]*Holder, 0, len(holdersSet))
	for addr, amount := range holdersSet {
		holdersSlice = append(holdersSlice, &Holder{
			Address: addr.Hex(),
			Amount:  amount.String(),
		})
	}

	return &SaveData{
		HoldersSet:      holdersSlice,
		LastBlockNumber: currentBlock.String(),
	}
}

// FetchTokenHolders fetches the token holders from a given contract
func fetchTokenHolders(
	client *ethclient.Client,
	contractABI abi.ABI,
	contractAddress common.Address,
	startBlock, latestBlock *big.Int,
) (map[common.Address]*big.Int, error) {
	// Load saved data
	savedData, err := loadSavedData(contractAddress)
	if err != nil {
		return nil, fmt.Errorf("failed to load saved data: %v", err)
	}

	currentBlock := new(big.Int).Set(startBlock)
	holdersSet := make(map[common.Address]*big.Int)
	if savedData != nil {
		for _, holder := range savedData.HoldersSet {
			address := common.HexToAddress(holder.Address)
			amount := new(big.Int)
			amount.SetString(holder.Amount, 10)
			holdersSet[address] = amount
		}
		currentBlock.SetString(savedData.LastBlockNumber, 10)
	}

	endBlock := new(big.Int).Set(latestBlock)

	for currentBlock.Cmp(endBlock) < 0 {
		fmt.Printf("Fetching logs from block %d to block %d...\n", currentBlock, endBlock)
		toBlock := new(big.Int).Add(currentBlock, big.NewInt(queryStep))
		if toBlock.Cmp(endBlock) > 0 {
			toBlock.Set(endBlock)
		}

		query := ethereum.FilterQuery{
			FromBlock: currentBlock,
			ToBlock:   toBlock,
			Addresses: []common.Address{contractAddress},
			Topics:    [][]common.Hash{{contractABI.Events["Transfer"].ID}},
		}

		logs, err := client.FilterLogs(context.Background(), query)
		if err != nil {
			// Save data before returning the error
			savedData = prepareSaveData(holdersSet, currentBlock)
			saveErr := saveData(contractAddress, savedData)
			if saveErr != nil {
				return nil, fmt.Errorf("failed to save data: %v", saveErr)
			}
			return nil, fmt.Errorf("failed to fetch logs: %v", err)
		}

		for _, vLog := range logs {
			from := common.HexToAddress(vLog.Topics[1].Hex())
			to := common.HexToAddress(vLog.Topics[2].Hex())
			amount := new(big.Int).SetBytes(vLog.Data)

			if _, exists := holdersSet[from]; !exists {
				holdersSet[from] = big.NewInt(0)
			}
			if _, exists := holdersSet[to]; !exists {
				holdersSet[to] = big.NewInt(0)
			}

			holdersSet[from].Sub(holdersSet[from], amount)
			holdersSet[to].Add(holdersSet[to], amount)
		}

		currentBlock.Add(toBlock, big.NewInt(1))
	}
	RemoveZeroAmountHolders(holdersSet)
	// Prepare and save data
	savedData = prepareSaveData(holdersSet, currentBlock)
	if err := saveData(contractAddress, savedData); err != nil {
		return nil, fmt.Errorf("failed to save data: %v", err)
	}

	return holdersSet, nil
}

// TotalSumOfHoldersSet calculates the total sum of tokens in the holdersSet
func TotalSumOfHoldersSet(holdersSet map[common.Address]*big.Int) *big.Int {
	totalSum := big.NewInt(0)
	for _, amount := range holdersSet {
		totalSum.Add(totalSum, amount)
	}
	return totalSum
}

// RemoveZeroAmountHolders removes all addresses with a 0 amount from the holdersSet
func RemoveZeroAmountHolders(holdersSet map[common.Address]*big.Int) {
	delete(holdersSet, common.HexToAddress("0x0000000000000000000000000000000000000000"))

	for addr, amount := range holdersSet {
		if amount.Cmp(big.NewInt(0)) == 0 {
			delete(holdersSet, addr)
		}
	}
}

type h struct {
	Address common.Address
	Amount  *big.Int
}

// OrderHoldersByAmount orders the holders by amount from highest to lowest
func OrderHoldersByAmount(holdersSet map[common.Address]*big.Int) []h {
	var holders []h
	for address, amount := range holdersSet {
		holders = append(holders, h{
			Address: address,
			Amount:  amount,
		})
	}

	sort.Slice(holders, func(i, j int) bool {
		return holders[i].Amount.Cmp(holders[j].Amount) > 0
	})

	return holders
}

func generateScript(client *ethclient.Client, holders map[common.Address]*big.Int, newToken, target string) {
	// Order holders by amount
	orderedHolders := OrderHoldersByAmount(holders)

	// Generate mint commands
	mints := ""
	for _, holder := range orderedHolders {
		mints += fmt.Sprintf("        token.mint(%s, %s);\n", holder.Address.Hex(), holder.Amount.String())
	}

	solidityContent := fmt.Sprintf(`// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Token.sol";
import "../src/BlacklistValidatorUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BatchMint is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenAddress = %s;
        address targetAddress = %s;
        address devKey = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        Token token = Token(tokenAddress);
        ERC20 target = ERC20(targetAddress);

        token.addAdminAccount(devKey);
        token.addSystemAccount(devKey);

        token.setMaxMintAllowance(target.totalSupply());
        token.setMintAllowance(devKey, target.totalSupply());
        console.log("mint allowance set successfully.");

%s
        console.log("minting completed successfully.");
        require(token.totalSupply() == target.totalSupply(), "balances are not fully copied.");
        console.log("balances are fully copied");

        token.removeAdminAccount(devKey);
        token.removeSystemAccount(devKey);
        vm.stopBroadcast();
    }
}`, newToken, target, mints)

	outputPath := filepath.Join("..", fmt.Sprintf("BatchMint-%s.s.sol", target))
	err := os.WriteFile(outputPath, []byte(solidityContent), 0644)
	if err != nil {
		log.Fatalf("Failed to write Solidity script: %v", err)
	}

	fmt.Printf("Solidity script BatchMint.sol has been generated at %s.\n", outputPath)
}
