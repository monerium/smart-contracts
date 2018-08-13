// artifacts
var TokenStorageLib = artifacts.require("./TokenStorageLib.sol");
var StandardController = artifacts.require("./StandardController.sol");

module.exports = function(deployer) {

  deployer.link(TokenStorageLib, StandardController);
  deployer.deploy(StandardController, 0x0, 50000);

};
