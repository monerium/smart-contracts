var SmartController = artifacts.require("./SmartController.sol");
var TokenFrontend = artifacts.require("./TokenFrontend.sol");

module.exports = async function (exit) {
  if (process.argv.length < 7) {
    console.log(
      `Usage: ${process.argv.join(" ")} <token> <account> <amount-in-wei>`
    );
    exit(1);
  }

  const len = process.argv.length;
  const address = process.argv[len - 3];
  const account = process.argv[len - 2];
  const amount = process.argv[len - 1];
  console.log(`Removing ${amount} token from ${account}`);

  try {
    const token = await TokenFrontend.at(address);
    const x = await token.getController();
    console.log(`token: ${address}, controller: ${x}`);
    const controller = await SmartController.at(x);
    const tx = await controller.burnFrom(account, amount);
    console.log(tx);
    exit(0);
  } catch (e) {
    exit(e);
  }
};
