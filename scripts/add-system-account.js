var SmartController = artifacts.require("./SmartController.sol");
var TokenFrontend = artifacts.require("./TokenFrontend.sol");
var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");

module.exports = async function (exit) {
  if (process.argv.length < 6) {
    console.log(`Usage: ${process.argv.join(" ")} <token> <account>`);
    exit(1);
  }

  const len = process.argv.length;
  const address = process.argv[len - 2];
  const account = process.argv[len - 1];
  console.log(`adding ${account}`);

  try {
    const token = await TokenFrontend.at(address);
    const x = await token.getController();
    const controller = await SmartController.at(x);
    const v = await controller.getValidator();
    console.log(
      `token: ${address}, controller: ${x}, BlacklistValidator: ${v}`
    );
    const validator = await BlacklistValidator.at(v);
    const tx = await controller.addSystemAccount(account);
    console.log("controller addSystemAccount: ");
    console.log(tx);
    const tx2 = await validator.addSystemAccount(account);
    console.log("blacklistValidator addSystemAccount: ");
    console.log(tx2);
    exit(0);
  } catch (e) {
    exit(e);
  }
};
