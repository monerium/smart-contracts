var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");
var SmartController = artifacts.require("./SmartController.sol");
var PolygonPosEUR = artifacts.require("./PolygonPosEUR.sol");
var PolygonPosGBP = artifacts.require("PolygonPosGBP");
var PolygonPosISK = artifacts.require("PolygonPosISK");
var PolygonPosUSD = artifacts.require("PolygonPosUSD");
var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var TokenStorageLib = artifacts.require("./TokenStorageLib.sol");
var SmartTokenLib = artifacts.require("./SmartTokenLib.sol");
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var ERC677Lib = artifacts.require("./ERC677Lib.sol");

const ChildChainManagerProxyMumbai = "0xb5505a6d998549090530911180f38aC5130101c6";
const ChildChainManagerProxyMainnet = "0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa";
var childChainManagerProxy = "0x0000000000000000000000000000000000000000";

module.exports = function(deployer, network) {
  // Set the correct Chain Manager Address. On Localchain, the address is 0x;
  if (network.startsWith('polygon_pos_mumbai'))
    childChainManagerProxy = ChildChainManagerProxyMumbai;
  else
    childChainManagerProxy = ChildChainManagerProxyMainnet;
  // Only to be deployed on polygon's networks or local chain.
  if (network.startsWith('polygon') || network.startsWith('poa') || network.startsWith('monerium') || network.startsWith('dashboard')) {
    deployer.link(SmartTokenLib, SmartController);
    deployer.link(TokenStorageLib, SmartController);
    deployer.link(ERC20Lib, SmartController);
    deployer.link(ERC677Lib, SmartController);
    deployer.link(MintableTokenLib, SmartController);

    deployer.deploy(PolygonPosEUR, childChainManagerProxy).then(frontend =>
      deployer.deploy(SmartController, '0x0000000000000000000000000000000000000000', BlacklistValidator.address, web3.utils.asciiToHex("EUR"), frontend.address).then(controller => {
        if (network.startsWith('poa'))
          controller.addSystemAccount('0x913dA4198E6bE1D5f5E4a40D0667f70C0B5430Eb');
        return frontend.setController(controller.address);
    }));

    deployer.deploy(PolygonPosGBP, childChainManagerProxy).then(frontend =>
      deployer.deploy(SmartController, '0x0000000000000000000000000000000000000000', BlacklistValidator.address, web3.utils.asciiToHex("GBP"), frontend.address).then(controller => {
        if (network.startsWith('poa'))
          controller.addSystemAccount('0x913dA4198E6bE1D5f5E4a40D0667f70C0B5430Eb');
        return frontend.setController(controller.address);
    }));

    deployer.deploy(PolygonPosISK, childChainManagerProxy).then(frontend =>
      deployer.deploy(SmartController, '0x0000000000000000000000000000000000000000', BlacklistValidator.address, web3.utils.asciiToHex("ISK"), frontend.address).then(controller => {
        if (network.startsWith('poa'))
          controller.addSystemAccount('0x913dA4198E6bE1D5f5E4a40D0667f70C0B5430Eb');
        return frontend.setController(controller.address);
    }));

    deployer.deploy(PolygonPosUSD, childChainManagerProxy).then(frontend =>
      deployer.deploy(SmartController, '0x0000000000000000000000000000000000000000', BlacklistValidator.address, web3.utils.asciiToHex("USD"), frontend.address).then(controller => {
        if (network.startsWith('poa'))
          controller.addSystemAccount('0x913dA4198E6bE1D5f5E4a40D0667f70C0B5430Eb');
        return frontend.setController(controller.address);
    }));
  }
};
