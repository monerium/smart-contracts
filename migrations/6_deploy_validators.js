var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");

module.exports = function (deployer) {

  deployer.deploy(BlacklistValidator);

};
