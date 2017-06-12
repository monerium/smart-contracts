var ConvertLib = artifacts.require("./ConvertLib.sol");
var MetaCoin = artifacts.require("./MetaCoin.sol");
var SafeMathLib = artifacts.require("./SafeMathLib.sol");
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var StandardToken = artifacts.require("./StandardToken.sol")

module.exports = function(deployer) {
  // MetaCoin
  deployer.deploy(ConvertLib);
  deployer.link(ConvertLib, MetaCoin);
  deployer.deploy(MetaCoin);

  // StandardToken
  deployer.deploy(SafeMathLib);
  deployer.link(SafeMathLib, ERC20Lib, StandardToken);
  deployer.deploy(ERC20Lib);
  deployer.link(ERC20Lib, StandardToken);
  deployer.deploy(StandardToken);
};
