const SmartController = artifacts.require("./SmartController.sol");
const TokenFrontend = artifacts.require("./TokenFrontend.sol");
const UpgradeController = artifacts.require("./UpgradeController.sol");
const readline = require("readline");

module.exports = async function (exit) {
  if (process.argv.length <= 6) {
    console.log(
      `Usage: ${process.argv.join(
        " "
      )} <target frontend> <script contract> <owner> <controller>`
    );
    exit(1);
  }

  const frontend = process.argv[process.argv.length - 4];
  const scriptContract = process.argv[process.argv.length - 3];
  const owner = process.argv[process.argv.length - 2];
  const controller = process.argv[process.argv.length - 1];

  try {
    // Parameters
    const token = await TokenFrontend.at(frontend);
    const ctlAddress = await token.getController();
    const script = await UpgradeController.at(scriptContract);

    console.log(`Frontend: ${frontend}`);
    console.log(`Owner: ${owner}`);
    console.log(`Controller to revert to: ${controller}`);
    console.log(`Controller linked: ${ctlAddress}`);
    console.log(`Upgrader: ${scriptContract}`);

    await confirmExecution();
    // Executing script
    console.log("#2 Reverting to the last controller on-chain:");
    const txRevertToLastController = await script.revertToLastController(
      controller, // new controller address
      ctlAddress, // old controller address
      frontend, // frontend address
      owner // owner address
    );
    console.log(txRevertToLastController);
    const newCtrl = await token.getController();
    console.log(`New Controller: ${newCtrl}`);
    exit(0);
  } catch (e) {
    exit(e);
  }
};

function confirmExecution() {
  return new Promise((resolve, reject) => {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
    });

    rl.question("Do you wish to continue? (Y/n) ", (answer) => {
      rl.close();
      if (answer.toLowerCase() === "n") {
        exit(0);
      } else {
        resolve();
      }
    });
  });
}
