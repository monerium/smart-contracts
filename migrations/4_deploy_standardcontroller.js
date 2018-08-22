// artifacts
var TokenStorageLib = artifacts.require("./TokenStorageLib.sol");
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var ERC677Lib = artifacts.require("./ERC677Lib.sol");
var StandardController = artifacts.require("./StandardController.sol");

module.exports = function(deployer) {

  deployer.link(TokenStorageLib, StandardController);
  deployer.link(ERC20Lib, StandardController);
  deployer.link(ERC677Lib, StandardController);
  deployer.deploy(StandardController, 0x0, 50000);

};
