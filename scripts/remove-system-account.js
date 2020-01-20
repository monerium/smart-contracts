var SmartController = artifacts.require("./SmartController.sol");
var TokenFrontend = artifacts.require("./TokenFrontend.sol");

module.exports = async function(exit) {

  if (process.argv.length < 6) {
    console.log(`Usage: ${process.argv.join(" ")} <token> <account>`)
    exit(1);
  }

  const len = process.argv.length;
  const address = process.argv[len-2];
  const account = process.argv[len-1];
  console.log(`removing ${account}`);

  try {
    const token = await TokenFrontend.at(address);
    const x = await token.getController();
    console.log(`token: ${address}, controller: ${x}`);
    const controller = await SmartController.at(x);
    const tx = await controller.removeSystemAccount(account);
    console.log(tx);
    exit(0);
  } catch (e) {
    exit(e);
  }
}
