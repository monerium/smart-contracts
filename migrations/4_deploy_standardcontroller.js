// artifacts
var SafeMathLib = artifacts.require("./SafeMathLib.sol");
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var SmartTokenLib = artifacts.require("./SmartTokenLib.sol");
var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");
var ConstantValidator = artifacts.require("./ConstantValidator.sol");

var TokenStorageLib = artifacts.require("./TokenStorageLib.sol");
var TokenStorage = artifacts.require("./TokenStorage.sol");
var StandardController = artifacts.require("./StandardController.sol");
var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var MintableController = artifacts.require("./MintableController.sol");
var SmartController = artifacts.require("./SmartController.sol");
var ConstantSmartController = artifacts.require("./ConstantSmartController.sol");
var USD = artifacts.require("./USD.sol");
var EUR = artifacts.require("./EUR.sol");

// TODO: Registry?

module.exports = function(deployer) {

  // deploy and link controllers
  // deployer.link(TokenStorageLib, ConstantSmartController);
  // deployer.link(ERC20Lib, ConstantSmartController);
  // deployer.link(MintableTokenLib, ConstantSmartController);
  // deployer.link(SmartTokenLib, ConstantSmartController);

  // deployer.deploy([[TokenStorage, 10000], [StandardController, 0x0, 50000]]);
  // deployer.link(MintableTokenLib, [MintableController, SmartController]);
  // deployer.deploy(MintableController, 0x0, 0x0, 0);

  deployer.link(TokenStorageLib, StandardController);
  deployer.deploy(StandardController, 0x0, 50000);
};
