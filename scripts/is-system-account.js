var SmartController = artifacts.require("./SmartController.sol");

module.exports = async function(exit) {

  if (process.argv.length != 5) {
    console.log(`Usage: ${process.argv.join(" ")} <account>`)
    exit(1);
  }

  const account = process.argv[4];
  console.log(`checking ${account}`);

  try {
    const controller = await SmartController.deployed();
    const tx = await controller.isSystemAccount(account);
    console.log(tx);
    exit(0);
  } catch (e) {
    exit(e);
  }
}
