// var ConvertLib = artifacts.require("./ConvertLib.sol");
// var MetaCoin = artifacts.require("./MetaCoin.sol");
var SafeMathLib = artifacts.require("./SafeMathLib.sol");
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var SmartTokenLib = artifacts.require("./SmartTokenLib.sol");
var SmartController = artifacts.require("./SmartController.sol");
var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");
var USD = artifacts.require("./USD.sol");
var EUR = artifacts.require("./EUR.sol");


// TODO: Registry?

module.exports = function(deployer) {
  // MetaCoin
  // deployer.deploy(ConvertLib);
  // deployer.link(ConvertLib, MetaCoin);
  // deployer.deploy(MetaCoin);

  // SafeMathLib, ERC2Lib & SmartTokenLib, BlacklistValidator
  deployer.deploy(SafeMathLib);
  deployer.link(SafeMathLib, [ERC20Lib, MintableTokenLib]);
  deployer.deploy([ERC20Lib, MintableTokenLib, SmartTokenLib, BlacklistValidator]);

  // SmartToken
  deployer.link(ERC20Lib, SmartController);
  deployer.link(MintableTokenLib, SmartController);
  deployer.link(SmartTokenLib, SmartController);

  // USD
  deployer.deploy(USD).then(() => {
    deployer.deploy(SmartController, USD.address, BlacklistValidator.address, "USD").then(() => {
      USD.at(USD.address).setController(SmartController.address);
    });
  });
//  // EUR
  deployer.deploy(EUR).then(() => {
    deployer.deploy(SmartController, EUR.address, BlacklistValidator.address, "EUR").then(() => {
      EUR.at(EUR.address).setController(SmartController.address);
    });
  });
};
