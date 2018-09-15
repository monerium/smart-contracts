require('dotenv').config();
const Web3 = require('web3');
const web3 = new Web3();
const WalletProvider = require('truffle-wallet-provider');
const Wallet = require('ethereumjs-wallet');

const key = process.env['KEY'];
const api = process.env['API'];
const url = process.env['URL'];

const wallet = Wallet.fromPrivateKey(Buffer.from(key, 'hex'));

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
			network_id: 2000,        // monerium testnet
			from: "0x253c61c9e3d1aa594761f7ef3f7cbe7a5151f9fd"
    },
		rinkeby: {
			network_id: 4,        // rinkeby
			// from: "0xB912740F1389fA0c99965fCda9039B9E5638e5f7",
			from: wallet.getAddressString(),
			gas: 4700000,
			gasPrice: web3.utils.toWei('1', 'gwei'),
			provider: () => new WalletProvider(wallet, `${url}/v3/${api}`)
			// optional config values:
			// gas
			// gasPrice
			// from - default address to use for any transaction Truffle makes during migrations
			// provider - web3 provider instance Truffle should use to talk to the Ethereum network.
			//          - if specified, host and port are ignored.
		},
  },
}
