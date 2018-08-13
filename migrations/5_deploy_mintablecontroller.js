// artifacts
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var TokenStorageLib = artifacts.require("./TokenStorageLib.sol");
var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var MintableController = artifacts.require("./MintableController.sol");

module.exports = function(deployer) {

  deployer.link(TokenStorageLib, MintableController);
  deployer.link(ERC20Lib, MintableController);
  deployer.link(MintableTokenLib, MintableController);
  deployer.deploy(MintableController, 0x0,  0);

};
