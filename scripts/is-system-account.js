var SmartController = artifacts.require("./SmartController.sol");

module.exports = async function(exit) {

  if (process.argv.length < 6) {
    console.log(`Usage: ${process.argv.join(" ")} <smart-controller> <account>`)
    exit(1);
  }

  const len = process.argv.length;
  const controller = process.argv[len-2];
  const account = process.argv[len-1];
  console.log(`checking ${account}`);

  try {
    const c = await SmartController.at(controller);
    const tx = await c.isSystemAccount(account);
    console.log(tx);
    exit(0);
  } catch (e) {
    exit(e);
  }
}
