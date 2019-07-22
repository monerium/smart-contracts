var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");
var SmartController = artifacts.require("./SmartController.sol");
var USD = artifacts.require("./USD.sol");

var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var SmartTokenLib = artifacts.require("./SmartTokenLib.sol");
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var ERC677Lib = artifacts.require("./ERC677Lib.sol");

module.exports = function(deployer, network) {

  deployer.link(SmartTokenLib, SmartController);
  deployer.link(ERC20Lib, SmartController);
  deployer.link(ERC677Lib, SmartController);
  deployer.link(MintableTokenLib, SmartController);

  return deployer.deploy(USD).then(frontend => 
    deployer.deploy(SmartController, 0x0, BlacklistValidator.address, "USD", frontend.address).then(controller => {
      frontend.setController(controller.address);
      if (network.startsWith('poa'))
        controller.addSystemAccount('0x913dA4198E6bE1D5f5E4a40D0667f70C0B5430Eb');
    }));

};
