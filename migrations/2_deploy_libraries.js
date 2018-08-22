// artifacts
var SafeMathLib = artifacts.require("zeppelin-solidity/math/SafeMath.sol");
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var SmartTokenLib = artifacts.require("./SmartTokenLib.sol");
var TokenStorageLib = artifacts.require("./TokenStorageLib.sol");
var TokenStorage = artifacts.require("./TokenStorage.sol");
var StandardController = artifacts.require("./StandardController.sol");
var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var MintableController = artifacts.require("./MintableController.sol");
var SmartController = artifacts.require("./SmartController.sol");

// TODO: Registry?

module.exports = function(deployer) {

  // deploy and link libraries
  deployer.deploy(SafeMathLib);
  deployer.link(SafeMathLib, [TokenStorageLib, ERC20Lib, MintableTokenLib]);
  deployer.deploy([TokenStorageLib, ERC20Lib]);
  deployer.link(TokenStorageLib, [TokenStorage]);
  deployer.link(ERC20Lib, [StandardController, SmartController, SmartTokenLib]);
  deployer.deploy([MintableTokenLib, SmartTokenLib]);
  deployer.link(MintableTokenLib, [MintableController, SmartTokenLib])

};
