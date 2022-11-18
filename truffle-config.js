const HDWalletProvider = require('@truffle/hdwallet-provider');
const toWei = new require('web3').utils.toWei;

const address = process.env['ADDRESS'];
const key = process.env['KEY'];
const mnemonic = process.env['MNEMONIC'];
const poahost = process.env['POA_HOST'];
const etherscanKey = process.env['ETHERSCAN_API'];
const polygonscanKey =  process.env['POLYGONSCAN_API'];

var url = process.env['URL'];
var walletProvider;

try {

  if (key != undefined || mnemonic != undefined) {

    if (address == undefined) {
      throw Error('ADDRESS not set');
    }
    if (url == undefined) {
      throw Error('URL not set');
    }

    walletProvider = new HDWalletProvider({
      mnemonic,
      privateKeys: [key],
      providerOrUrl: url,
      addressIndex: 0,
    });

    var walletAddress = walletProvider.getAddress();
    if (walletAddress != address.toLowerCase()) {
      throw Error(`Wallet address ${walletAddress} does not match ${address}`);
    }

  } else {
    console.log("WARNING: both KEY and MNEMONIC undefined");
  }

} catch (e) {
  console.log(e.toString());
  process.exit();
}

module.exports = {

  networks: {
    development: {
      host: "localhost",
      port: 9545,
      network_id: "*", // Match any network id
    },
    poa: {
      host: poahost != undefined ? poahost : "localhost",
      port: 8545,
      network_id: 100,
    },
    monerium: {
      host: "e.monerium.com",
      port: 8549,
      network_id: 2000,   // monerium testnet
      from: "0x253c61c9e3d1aa594761f7ef3f7cbe7a5151f9fd",
    },
    rinkeby: {
      network_id: 4,      // rinkeby
      from: address,
      gas: 6800000,       // balance between out of gas errors and block gas limit errors
      gasPrice: toWei('41', 'gwei'), // average gas price on rinkeby
      provider: () => walletProvider,
    },
    ropsten: {
      provider: () => walletProvider,
      network_id: 3,
      gas: 6800000,
      from: address,
      gasPrice: toWei('41', 'gwei'),
    },
    kovan: {
      provider: () => walletProvider,
      network_id: 42,
      gas: 4600000,
      from: address,
      gasPrice: toWei('41', 'gwei'),
    },
    goerli: {
      provider: () => walletProvider,
      network_id: 5,
      gas: 5000000,
      from: address,
      gasPrice: toWei('10', 'gwei'),
      timeoutBlocks: 200,
      skipDryRun: true,
    },
    polygon_pos_mainnet: {
      provider: () => walletProvider,
      network_id: 137,
      confirmation: 2,
      timeoutBlocks: 200,
      chainId: 137,
      gas: 4465030,
    },
    dashboard: {
      network_id: 137,
      confirmation: 2,
      timeoutBlocks: 200,
      chainId: 137,
      gas: 4465030,
      maxPriorityFeePerGas: toWei('40', 'gwei'),
      maxFee: toWei('41'),
    },
    polygon_pos_mumbai: {
      provider: () => walletProvider,
      network_id: 80001,
      confirmation: 2,
      timeoutBlocks: 200,
      chainId: 80001,
      gas: 4465030,
      gasPrice: toWei('41', 'gwei'),
    },
    mainnet: {
      provider: () => walletProvider,
      network_id: 1,
      gas: 6800000,
      from: address,
      gasPrice: toWei('15', 'gwei'),
    },
  },

  compilers: {
    solc: {
      version: "0.8.11",    // fetch exact version from solc-bin (default: truffle's version)
      settings: {           // see the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 1000
        },
      },
    },
  },

  plugins: [
    'truffle-plugin-verify',
    'solidity-coverage',
  ],

  api_keys: {
    etherscan: etherscanKey,
    polygonscan: polygonscanKey,
  },

  mocha: {
    reporter: 'eth-gas-reporter',
    reporterOptions: {
      excludeContracts: ['Migrations'],
    },
  },

};
