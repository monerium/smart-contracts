// artifacts
var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var SmartTokenLib = artifacts.require("./SmartTokenLib.sol");
var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");
var TokenStorageLib = artifacts.require("./TokenStorageLib.sol");
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var ERC677Lib = artifacts.require("./ERC677Lib.sol");
var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var SmartController = artifacts.require("./SmartController.sol");

module.exports = function(deployer) {

  deployer.link(TokenStorageLib, SmartController);
  deployer.link(SmartTokenLib, SmartController);
  deployer.link(ERC20Lib, SmartController);
  deployer.link(ERC677Lib, SmartController);
  deployer.link(MintableTokenLib, SmartController);
  deployer.deploy(SmartController, 0x0, BlacklistValidator.address, "XXX");

};
