var SmartController = artifacts.require("./SmartController.sol");
var TokenFrontend = artifacts.require("./TokenFrontend.sol");

module.exports = async function(exit) {

  if (process.argv.length < 6) {
    console.log(`Usage: ${process.argv.join(" ")} <token> <new owner>`)
    exit(1);
  }

  const len = process.argv.length;
  const address = process.argv[len-2];
  const account = process.argv[len-1];
  console.log(`token ${address} to ${account}`);

  try {
    const token = await TokenFrontend.at(address);
    const tx1 = await token.transferOwnership(account);
    console.log(tx1);
    const x = await token.getController();
    console.log(`controller ${x} to ${account}`);
    const controller = await SmartController.at(x);
    const tx2 = await controller.transferOwnership(account);
    console.log(tx2);
    exit(0);
  } catch (e) {
    exit(e);
  }
}
