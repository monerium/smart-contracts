// artifacts
var SimpleToken = artifacts.require("./SimpleToken.sol");

module.exports = function(deployer) {

  deployer.deploy(SimpleToken);

};
