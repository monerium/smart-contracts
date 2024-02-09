var SmartController = artifacts.require("./SmartController.sol");
var TokenFrontend = artifacts.require("./TokenFrontend.sol");

module.exports = async function (exit) {
  if (process.argv.length < 6) {
    console.log(`Usage: ${process.argv.join(" ")} <token> <account> <amount>`);
    exit(1);
  }

  const len = process.argv.length;
  const address = process.argv[len - 3];
  const account = process.argv[len - 2];
  const amount = process.argv[len - 1];
  console.log(
    `set max mint allowance's amount to: ${amount} for account: ${account}`
  );

  try {
    const token = await TokenFrontend.at(address);
    const x = await token.getController();
    const controller = await SmartController.at(x);

    console.log(`token: ${address}, controller: ${x}`);

    const tx = await controller.setMintAllowance(account, amount);

    console.log("controller setMintAllowance: ");
    console.log(tx);

    exit(0);
  } catch (e) {
    exit(e);
  }
};
