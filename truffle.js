module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    }
  }
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
		}
};
