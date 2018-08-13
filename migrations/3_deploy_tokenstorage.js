// artifacts
var TokenStorageLib = artifacts.require("./TokenStorageLib.sol");
var TokenStorage = artifacts.require("./TokenStorage.sol");

module.exports = function(deployer) {

  deployer.link(TokenStorageLib, TokenStorage);
  deployer.deploy(TokenStorage, 10000);

};
