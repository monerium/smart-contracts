// artifacts
var ConstantValidator = artifacts.require("./ConstantValidator.sol");

module.exports = function(deployer, network) {

  if (network.startsWith('develop') == false) return;

  deployer.deploy(ConstantValidator, true);

};
