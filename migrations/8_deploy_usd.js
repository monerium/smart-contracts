var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");
var SmartController = artifacts.require("./SmartController.sol");
var USD = artifacts.require("./USD.sol");

module.exports = function(deployer) {

  deployer.deploy(SmartController, 0x0, BlacklistValidator.address, "USD").then(() => {
    return deployer.deploy(USD, SmartController.address);
  });

};
