var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");
var SmartController = artifacts.require("./SmartController.sol");
var GBP = artifacts.require("./GBP.sol");

var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var TokenStorageLib = artifacts.require("./TokenStorageLib.sol");
var SmartTokenLib = artifacts.require("./SmartTokenLib.sol");
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var ERC677Lib = artifacts.require("./ERC677Lib.sol");

module.exports = function(deployer, network) {
  if (network.startsWith('polygon'))
    return ;
  deployer.link(SmartTokenLib, SmartController);
  deployer.link(TokenStorageLib, SmartController);
  deployer.link(ERC20Lib, SmartController);
  deployer.link(ERC677Lib, SmartController);
  deployer.link(MintableTokenLib, SmartController);

  return deployer.deploy(GBP).then(frontend => 
    deployer.deploy(SmartController, '0x0000000000000000000000000000000000000000', BlacklistValidator.address, web3.utils.asciiToHex("GBP"), frontend.address).then(controller => {
      if (network.startsWith('poa'))
        controller.addSystemAccount('0x913dA4198E6bE1D5f5E4a40D0667f70C0B5430Eb');
      return frontend.setController(controller.address);
    }));

};
