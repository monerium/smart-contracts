var SmartController = artifacts.require("./SmartController.sol");
var TokenFrontend = artifacts.require("./TokenFrontend.sol");

module.exports = async function (exit) {
  if (process.argv.length < 5) {
    console.log(`Usage: ${process.argv.join(" ")} <token>`);
    exit(1);
  }

  const len = process.argv.length;
  const address = process.argv[len - 1];
  console.log(`token ${address}`);

  try {
    const token = await TokenFrontend.at(address);
    const tx1 = await token.claimOwnership();
    console.log(tx1);
    const x = await token.getController();
    console.log(`controller ${x}`);
    const controller = SmartController.at(x);
    const tx2 = await controller.claimOwnership();
    console.log(tx2);
    exit(0);
  } catch (e) {
    exit(e);
  }
};
