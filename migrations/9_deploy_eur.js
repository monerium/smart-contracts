// artifacts
var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");
var SmartController = artifacts.require("./SmartController.sol");
var EUR = artifacts.require("./EUR.sol");

module.exports = function(deployer) {

  return deployer.deploy(SmartController, 0x0, BlacklistValidator.address, "EUR").then(() => {
    return deployer.deploy(EUR, SmartController.address);
  });

};
