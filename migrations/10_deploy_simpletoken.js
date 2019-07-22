var SimpleToken = artifacts.require("./SimpleToken.sol");

module.exports = function (deployer, network) {

  if (network.startsWith('develop') == false) return;

  deployer.deploy(SimpleToken);

};
