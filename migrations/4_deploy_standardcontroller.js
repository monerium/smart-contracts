// artifacts
var TokenStorageLib = artifacts.require("./TokenStorageLib.sol");
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var ERC677Lib = artifacts.require("./ERC677Lib.sol");
var StandardController = artifacts.require("./StandardController.sol");
var AcceptingRecipient = artifacts.require("./AcceptingRecipient.sol");
var RejectingRecipient = artifacts.require("./RejectingRecipient.sol");

module.exports = function(deployer, network) {

  if (network.startsWith('develop') == false) return;

  deployer.link(TokenStorageLib, StandardController);
  deployer.link(ERC20Lib, StandardController);
  deployer.link(ERC677Lib, StandardController);
  deployer.deploy(StandardController, 0x0, 50000, 0x0);
  deployer.deploy(AcceptingRecipient);
  deployer.deploy(RejectingRecipient);

};
