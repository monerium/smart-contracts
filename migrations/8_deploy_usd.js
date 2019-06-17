var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");
var SmartController = artifacts.require("./SmartController.sol");
var USD = artifacts.require("./USD.sol");

var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var SmartTokenLib = artifacts.require("./SmartTokenLib.sol");
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var ERC677Lib = artifacts.require("./ERC677Lib.sol");

module.exports = function(deployer) {

  deployer.link(SmartTokenLib, SmartController);
  deployer.link(ERC20Lib, SmartController);
  deployer.link(ERC677Lib, SmartController);
  deployer.link(MintableTokenLib, SmartController);

  return deployer.deploy(USD).then(frontend => 
    deployer.deploy(SmartController, 0x0, BlacklistValidator.address, "USD", frontend.address).then(controller => 
      frontend.setController(controller.address)));

};
