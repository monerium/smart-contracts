require('dotenv').config();
const Web3 = require('web3');
const web3 = new Web3();
const WalletProvider = require('truffle-wallet-provider');
const Wallet = require('ethereumjs-wallet');

const key = process.env['KEY'];
const api = process.env['API'];
const url = process.env['URL'];

const wallet = key ? Wallet.fromPrivateKey(Buffer.from(key, 'hex')) : null;

// if this is a function return a wallet provider truffle will reinstantiate
// the wallet provider possibly losing (and reusing) nonces, resulting in
// replacement transaction underpriced errors.
const walletProvider = 
	 wallet ? new WalletProvider(wallet, `${url}/v3/${api}`) : null;

const address = 
	wallet ? wallet.getAddressString() : null;

if (address && address != "0xb912740f1389fa0c99965fcda9039b9e5638e5f7") {
  console.log("Wrong key");
  return;
}

module.exports = {
	networks: {
		development: {
			host: "localhost",
			port: 9545,
			network_id: "*" // Match any network id
		},
		poa: {
			host: "localhost",
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
			gasPrice: web3.utils.toWei('1', 'gwei'), // average gas price on rinkeby
			provider: () => walletProvider
			// optional config values:
			// gas
			// gasPrice
			// from - default address to use for any transaction Truffle makes during migrations
			// provider - web3 provider instance Truffle should use to talk to the Ethereum network.
			//          - if specified, host and port are ignored.
		},
  },
}
