// artifacts
var SimpleToken = artifacts.require("./SimpleToken.sol");

module.exports = function(deployer) {

  if (web3.version.network <= 100) return;

  deployer.deploy(SimpleToken);

};
