// artifacts
var TokenStorageLib = artifacts.require("./TokenStorageLib.sol");
var TokenStorage = artifacts.require("./TokenStorage.sol");

module.exports = function(deployer) {

  if (web3.version.network <= 100) return;

  deployer.link(TokenStorageLib, TokenStorage);
  deployer.deploy(TokenStorage, 10000);

};
