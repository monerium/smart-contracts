module.exports = {
	networks: {
		development: {
			host: "localhost",
			port: 9545,
			network_id: "*" // Match any network id
		},
		monerium: {
			host: "e.monerium.com", // Random IP for example purposes (do not use)
			port: 8549,
			network_id: 2000,        // monerium testnet
			// from: "0x7c22a71d7db4601b1675ea81a93c67940319bdfc",
			from: "0x253c61c9e3d1aa594761f7ef3f7cbe7a5151f9fd"
			// gas: 3000000,
    },
		rinkeby: {
			host: "e", // Random IP for example purposes (do not use)
			port: 8547,
			network_id: 4,        // rinkeby
			// from: "0x7c22a71d7db4601b1675ea81a93c67940319bdfc",
			from: "0xB912740F1389fA0c99965fCda9039B9E5638e5f7",
      gas: 4000000,
			// optional config values:
			// gas
			// gasPrice
			// from - default address to use for any transaction Truffle makes during migrations
			// provider - web3 provider instance Truffle should use to talk to the Ethereum network.
			//          - if specified, host and port are ignored.
		},
  },
}
