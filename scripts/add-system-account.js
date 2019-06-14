var SmartController = artifacts.require("./SmartController.sol");

module.exports = async function(exit) {

  if (process.argv.length < 5) {
    console.log(`Usage: ${process.argv.join(" ")} <account>`)
    exit(1);
  }

  const len = process.argv.len;
  const account = process.argv[len-1];
  console.log(`adding ${account}`);

  try {
    const controller = await SmartController.deployed();
    const tx = await controller.addSystemAccount(account);
    console.log(tx);
    exit(0);
  } catch (e) {
    exit(e);
  }
}
