var SmartController = artifacts.require("./SmartController.sol");
var TokenFrontend = artifacts.require("./TokenFrontend.sol");
var BlacklistValidator = artifacts.require("BlacklistValidator");

module.exports = async function (exit) {
  if (process.argv.length < 6) {
    console.log(`Usage: ${process.argv.join(" ")} <token> <account>`);
    exit(1);
  }

  const len = process.argv.length;
  const address = process.argv[len - 2];
  const account = process.argv[len - 1];
  console.log(`banning ${account}`);

  try {
    const token = await TokenFrontend.at(address);
    const controllerAddress = await token.getController();
    const controller = await SmartController.at(controllerAddress);
    const blacklistValidatorAddress = await controller.getValidator();
    const blacklist = await BlacklistValidator.at(blacklistValidatorAddress);
    console.log(
      `token: ${address}, controller: ${controllerAddress}, validator: ${blacklistValidatorAddress}`
    );
    const tx = await blacklist.ban(account);
    console.log(tx);
    exit(0);
  } catch (e) {
    exit(e);
  }
};
