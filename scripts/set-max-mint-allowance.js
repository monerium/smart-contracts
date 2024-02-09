var SmartController = artifacts.require("./SmartController.sol");
var TokenFrontend = artifacts.require("./TokenFrontend.sol");

module.exports = async function (exit) {
  if (process.argv.length < 6) {
    console.log(`Usage: ${process.argv.join(" ")} <token> <amount>`);
    exit(1);
  }

  const len = process.argv.length;
  const address = process.argv[len - 2];
  const amount = process.argv[len - 1];
  console.log(`set max mint amount to: ${amount}`);

  try {
    const token = await TokenFrontend.at(address);
    const x = await token.getController();
    const controller = await SmartController.at(x);

    console.log(`token: ${address}, controller: ${x}`);

    const tx = await controller.setMaxMintAllowance(amount);

    console.log("controller setMaxMintAllowance: ");
    console.log(tx);

    exit(0);
  } catch (e) {
    exit(e);
  }
};
