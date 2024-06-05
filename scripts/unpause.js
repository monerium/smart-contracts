var SmartController = artifacts.require("./SmartController.sol");
var TokenFrontend = artifacts.require("./TokenFrontend.sol");

module.exports = async function (exit) {
  if (process.argv.length < 4) {
    console.log(`Usage: ${process.argv.join(" ")} <token> `);
    exit(1);
  }

  const len = process.argv.length;
  const address = process.argv[len - 1];
  console.log(`Unpausing: ${address}`);

  try {
    const token = await TokenFrontend.at(address);
    const x = await token.getController();
    const controller = await SmartController.at(x);

    console.log(`token: ${address}, controller: ${x}`);

    const tx = await controller.unpause();

    console.log("controller unpause: ");
    console.log(tx);

    exit(0);
  } catch (e) {
    exit(e);
  }
};
