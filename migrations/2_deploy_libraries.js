// artifacts
var SafeMathLib = artifacts.require("zeppelin-solidity/math/SafeMath.sol");
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var ERC677Lib = artifacts.require("./ERC677Lib.sol");
var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var SmartTokenLib = artifacts.require("./SmartTokenLib.sol");
var TokenStorageLib = artifacts.require("./TokenStorageLib.sol");
var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");

module.exports = function(deployer) {

  // deploy and link libraries
  deployer.deploy([SafeMathLib]);
  deployer.link(SafeMathLib, [TokenStorageLib, ERC20Lib, MintableTokenLib]);
  deployer.deploy([TokenStorageLib, ERC20Lib]);
  deployer.link(ERC20Lib, [SmartTokenLib, ERC677Lib]);
  deployer.deploy([ERC677Lib]);
  deployer.deploy([MintableTokenLib, SmartTokenLib]);
  deployer.link(MintableTokenLib, SmartTokenLib)

};
