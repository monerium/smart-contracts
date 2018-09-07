// artifacts
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var ERC677Lib = artifacts.require("./ERC677Lib.sol");
var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var TokenStorageLib = artifacts.require("./TokenStorageLib.sol");
var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var UIntLib = artifacts.require("./UIntLib.sol");
var MintableController = artifacts.require("./MintableController.sol");

module.exports = function(deployer) {

  if (web3.version.network <= 100) return;

  deployer.link(UIntLib, MintableController);
  deployer.link(TokenStorageLib, MintableController);
  deployer.link(ERC20Lib, MintableController);
  deployer.link(ERC677Lib, MintableController);
  deployer.link(MintableTokenLib, MintableController);
  deployer.deploy(MintableController, 0x0,  0);

};
