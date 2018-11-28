// artifacts
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var ERC677Lib = artifacts.require("./ERC677Lib.sol");
var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var TokenStorageLib = artifacts.require("./TokenStorageLib.sol");
var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var MintableController = artifacts.require("./MintableController.sol");

module.exports = function(deployer, network) {

  if (network.startsWith('develop') == false) return;

  deployer.link(TokenStorageLib, MintableController);
  deployer.link(ERC20Lib, MintableController);
  deployer.link(ERC677Lib, MintableController);
  deployer.link(MintableTokenLib, MintableController);
  deployer.deploy(MintableController, 0x0,  0);

};
