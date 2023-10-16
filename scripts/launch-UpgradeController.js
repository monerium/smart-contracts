const SmartController = artifacts.require("./SmartController.sol");
const TokenFrontend = artifacts.require("./TokenFrontend.sol");
const UpgradeController = artifacts.require("./UpgradeController.sol");
const readline = require('readline');

module.exports = async function (exit) {
  if (process.argv.length <= 9) {
    console.log(
      `Usage: ${process.argv.join(
        " "
      )} <target frontend> <script contract> <owner> <systemkey account> <admin> <maxMintAllowance>`
    );
    exit(1);
  }

  const frontend = process.argv[process.argv.length - 6];
  const scriptContract = process.argv[process.argv.length - 5];
  const owner = process.argv[process.argv.length - 4];
  const systemKeyAccount = process.argv[process.argv.length - 3];
  const admin = process.argv[process.argv.length - 2];
  const maxMintAllowance = process.argv[process.argv.length - 1];

  try {
    // Parameters
    const token = await TokenFrontend.at(frontend);
    const ctlAddress = await token.getController();
    const ctl = await SmartController.at(ctlAddress);
    const storage = await ctl.getStorage();
    const validator = await ctl.getValidator();
    const ticker = await ctl.ticker();
    const script = await UpgradeController.at(scriptContract);

    console.log(`Frontend: ${frontend}`);
    console.log(`Storage: ${storage}`);
    console.log(`Validator: ${validator}`);
    const tickerCharacterVersion = web3.utils.hexToAscii(ticker);
    console.log(`Ticker: ${ticker} (${tickerCharacterVersion.trim()})`);
    console.log(`Owner: ${owner}`);
    console.log(`System Key Account: ${systemKeyAccount}`);
    console.log(`Admin: ${admin}`);
    console.log(`Max Mint Allowance: ${maxMintAllowance}`);
    console.log(`Upgrader: ${scriptContract}`);

    await confirmExecution();
    // Executing script
    console.log("#2 Launching solidity scripts on chain:");
    const txScript = await script.launch(
      ctlAddress,
      frontend,
      storage,
      validator,
      ticker,
      owner,
      systemKeyAccount,
      admin,
      maxMintAllowance
    );
    console.log(txScript);
    
    const newCtrl = await token.getController();
    console.log(`New Controller: ${newCtrl}`);
    console.log("New Controller's constructor arguments:");
    console.log(`1. Storage(address): ${storage}`);
    console.log(`2. Validator(address): ${validator}`);
    console.log(`3. Ticker(bytes3): ${ticker} (${tickerCharacterVersion.trim()})`);
    console.log(`4. Frontend(address): ${frontend}`);

    console.log("\nPlease copy the logged value above for future use in contract validation");
    exit(0);
  } catch (e) {
    exit(e);
  }
};


function confirmExecution() {
  return new Promise((resolve, reject) => {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });

    rl.question('Do you wish to continue? (Y/n) ', answer => {
      rl.close();
      if (answer.toLowerCase() === 'n') {
        exit(0);
      } else {
        resolve();
      }
    });
  });
}

