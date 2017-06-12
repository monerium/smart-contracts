var ConvertLib = artifacts.require("./ConvertLib.sol");
var MetaCoin = artifacts.require("./MetaCoin.sol");
var SafeMathLib = artifacts.require("./SafeMathLib.sol");
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");
var SmartTokenLib = artifacts.require("./SmartTokenLib.sol");
var SmartToken = artifacts.require("./SmartToken.sol");
var TokenController = artifacts.require("./TokenController.sol");

module.exports = function(deployer) {
  // MetaCoin
  deployer.deploy(ConvertLib);
  deployer.link(ConvertLib, MetaCoin);
  deployer.deploy(MetaCoin);

  // SafeMathLib, ERC2Lib & SmartTokenLib
  deployer.deploy(SafeMathLib);
  deployer.link(SafeMathLib, ERC20Lib);
  deployer.deploy(ERC20Lib);
  deployer.deploy(SmartTokenLib);

  // BlacklistValidator
  deployer.deploy(BlacklistValidator).then(() => {
    // SmartToken
    deployer.link(ERC20Lib, SmartToken);
    deployer.link(SmartTokenLib, SmartToken);

    // USD
    deployer.deploy(SmartToken, BlacklistValidator.address, "Smart USD", "USDS").then(() => {
      deployer.deploy(TokenController, SmartToken.address);
    });
    // EUR
    deployer.deploy(SmartToken, BlacklistValidator.address, "Smart EUR", "EURS").then(() => {
      deployer.deploy(TokenController, SmartToken.address);
    });
  });
};
