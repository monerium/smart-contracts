// artifacts
var ConstantSmartController = artifacts.require("./ConstantSmartController.sol");
var TokenStorage = artifacts.require("./TokenStorage.sol");
var SmartTokenLib = artifacts.require("./SmartTokenLib.sol");
var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");
var TokenStorageLib = artifacts.require("./TokenStorageLib.sol");
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var ERC677Lib = artifacts.require("./ERC677Lib.sol");

module.exports = function(deployer, network) {

  if (network.startsWith('develop') == false) return;

  deployer.link(TokenStorageLib, ConstantSmartController);
  deployer.link(SmartTokenLib, ConstantSmartController);
  deployer.link(ERC20Lib, ConstantSmartController);
  deployer.link(ERC677Lib, ConstantSmartController);
  deployer.deploy(ConstantSmartController, TokenStorage.address, "USD");

};
