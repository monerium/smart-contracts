const SmartController = artifacts.require("./SmartController.sol");
const TokenFrontend = artifacts.require("./TokenFrontend.sol");
const UpgradeController = artifacts.require("./UpgradeController.sol");
const readline = require('readline');

module.exports = async function (exit) {
  if (process.argv.length <= 6) {
    console.log(
      `Usage: ${process.argv.join(
        " "
      )} <script contract> <owner>`
    );
    exit(1);
  }

  const upgrader = process.argv[process.argv.length - 2];
  const owner = process.argv[process.argv.length - 1];

  try {
    // Parameters
    const script = await UpgradeController.at(upgrader);

    console.log(`Upgrader: ${upgrader}`);
    console.log(`Owner: ${owner}`);

    // Executing script
    console.log("transferOwnership:");
    const txScript = await script.transferOwnership(owner);
    console.log(txScript);

    exit(0);
  } catch (e) {
    exit(e);
  }
};

