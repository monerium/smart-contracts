const fs = require('fs');
if (fs.existsSync('.env')) {
  result = require('dotenv').config();
  if (result.error) {
    console.log(result.error.toString())
  }
}
const Web3 = require('web3');
const web3 = new Web3();
const WalletProvider = require('@truffle/hdwallet-provider');
const bip39 = require('bip39');
const ethers = require('ethers');

const testkey = process.env['TESTKEY'];
const key = process.env['KEY'];
const api = process.env['API'];
const url = process.env['URL'];
const mnemonic = process.env['MNEMONIC'];
const ledger = process.env['LEDGER'];
const networkId = process.env['NETWORK_ID'];
const poahost = process.env['POA_HOST'];
const polygonscanAPI = process.env['POLYGONSCAN_API'];
const etherscanAPI = process.env['ETHERSCAN_API'];

var address;
var walletProvider;

function die(s) {
  console.error(s);
  process.exit();
}

if (key != undefined) {
  if (api == undefined) die('API not set')
  if (url == undefined) die('URL not set')
  address = `0xb912740f1389fa0c99965fcda9039b9e5638e5f7`;
  const wallet = ethers.Wallet(Buffer.from(key, 'hex'));
  const walletAddress = wallet.address;
  if (walletAddress != address) die(`Key address ${walletAddress} does not match ${address}`);
  walletProvider = () => new WalletProvider(key, `${url}/v3/${api}`, 0);
} else if (mnemonic != undefined) {
  if (api == undefined) die('API not set')
  if (url == undefined) die('URL not set')
  // address = `0x808b6dB94ce973Bab908450E764Db7405A533FAa`;
  //address = `0xe90319CBACc28aA19c12A7225322Ce64e5701D56`;
  address = "0x798728D5410aB4FB49d2C277A49baC5048aB43ca";

  if (!bip39.validateMnemonic(mnemonic)) die(`${mnemonic} not valid`);
  var wallet = ethers.Wallet.fromMnemonic(mnemonic);
  const walletAddress = wallet.address;
  if (walletAddress != address) die(`Key address ${walletAddress} does not match ${address}`);
  walletProvider = () => new WalletProvider(mnemonic, `${url}/v3/${api}`, 0);
} else if (testkey != undefined) {
  if (api == undefined) die('API not set')
  if (url == undefined) die('URL not set')
  const wallet = ethers.Wallet(Buffer.from(testkey, 'hex'));
  const walletAddress = wallet.address;
  address = walletAddress;
  walletProvider = () => new WalletProvider(testkey, `${url}/v3/${api}`, 0);
}  else if (ledger != undefined) {
  if (api == undefined) die('API not set')
  if (url == undefined) die('URL not set')
  if (networkId == undefined) die('NETWORK_ID not set')
  const ledgerOptions = {
    networkId: networkId,
    path: "44'/60'/0'/0/0", // ledger default derivation path
    askConfirm: false,
    accountsLength: 1,
    accountsOffset: 0
  };
}

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 9545,
      network_id: "*" // Match any network id
    },
    poa: {
      host: poahost != undefined ? poahost : "localhost",
      port: 8545,
      network_id: 100
    },
    monerium: {
      host: "e.monerium.com",
      port: 8549,
      network_id: 2000,   // monerium testnet
      from: "0x253c61c9e3d1aa594761f7ef3f7cbe7a5151f9fd"
    },
    rinkeby: {
      network_id: 4,      // rinkeby
      from: address,
      gas: 6800000,       // balance between out of gas errors and block gas limit errors
      gasPrice: web3.utils.toWei('41', 'gwei'), // average gas price on rinkeby
      provider: walletProvider,
    },
    ropsten: {
      provider: walletProvider,
      network_id: 3,
      gas: 6800000,
      from: address,
      gasPrice: web3.utils.toWei('41', 'gwei'),
    },
    kovan: {
      provider: walletProvider,
      network_id: 42,
      gas: 4600000,
      from: address,
      gasPrice: web3.utils.toWei('41', 'gwei'),
    },
    goerli: {
      provider: walletProvider,
      network_id: 5,
      gas: 4465030,
      from: address,
      gasPrice: web3.utils.toWei('10', 'gwei'),
      skipDryRun: true
    },
    polygon_pos_mainnet: {
      provider: walletProvider,
      network_id: 137,
      confirmation: 2,
      timeoutBlocks: 200,
      chainId: 137,
      gas: 4465030,
    },
    dashboard: {
      network_id: 137,
      confirmation: 2,
      from: "0xA176a20E3698bAa36Ea09E4499e407e7dbFdfa0c",
      timeoutBlocks: 200,
      chainId: 137,
      gas: 4465030,
      maxPriorityFeePerGas: web3.utils.toWei('40', 'gwei'),
      maxFee: web3.utils.toWei('41'),
    },
    polygon_pos_mumbai: {
      provider: walletProvider,
      network_id: 80001,
      confirmation: 2,
      timeoutBlocks: 200,
      chainId: 80001,
      gas: 4465030,
      gasPrice: web3.utils.toWei('41', 'gwei'),
    },
    mainnet: {
      provider: walletProvider,
      network_id: 1,
      gas: 6800000,
      from: address,
      gasPrice: web3.utils.toWei('15', 'gwei'),
    },
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.11",    // Fetch exact version from solc-bin (default: truffle's version)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 1000
        }
      }
    }
  },

  plugins: [
    'truffle-plugin-verify',
    'solidity-coverage'
  ],

  api_keys: {
    etherscan: etherscanAPI,
    polygonscan: polygonscanAPI
  },

  mocha: {
    reporter: 'eth-gas-reporter',
    reporterOptions: {
      excludeContracts: ['Migrations']
    }
  }

};
