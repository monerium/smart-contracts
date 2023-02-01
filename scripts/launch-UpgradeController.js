const SmartController = artifacts.require("./SmartController.sol");
const TokenFrontend = artifacts.require("./TokenFrontend.sol");
const UpgradeController = artifacts.require("./UpgradeController.sol");

module.exports = async function(exit) {
  if (process.argv.length <= 7) {
    console.log(`Usage: ${process.argv.join(" ")} <target frontend> <script contract> <systemkey account> <startAtStep - optional>`)
    exit(1);
  }

  var len = process.argv.length;
  var startAt = 0;
  if (len == 10) {
    startAt = process.argv[len - 1];
    len = len - 1;
  }
  const frontend = process.argv[len - 3];
  const scriptContract = process.argv[len - 2];
  const systemKeyAccount = process.argv[len - 1];

  try {
    // Parameters
    const token = await TokenFrontend.at(frontend)
    const ctlAddress = await token.getController();
    const ctl = await SmartController.at(ctlAddress);
    const storage = await ctl.getStorage();
    const validator = await ctl.getValidator();
    const ticker = await ctl.ticker();
    const script = await UpgradeController.at(scriptContract);

    console.log(`Frontend: ${frontend}`);
    console.log(`Storage: ${storage}`);
    console.log(`Validator: ${validator}`);
    console.log(`Ticker: ${ticker}`);

    // TransferOwnership 
    if (startAt <= 0) {
      console.log(`#0 TransferOwnership of Token (${frontend}) to Contract (${scriptContract}):`)
      const tx1 = await token.transferOwnership(scriptContract);
      console.log(tx1)
    }
    if (startAt <= 1) {
      console.log(`#1 TransferOwnership of Controller (${ctlAddress}) to Contract (${scriptContract}):`)
      const tx2 = await ctl.transferOwnership(scriptContract);
      console.log(tx2)
    }

    // Executing script
    if (startAt <= 2) {
      console.log("#2 Launching solidity scripts on chain:")
      const txScript = await script.launch(ctlAddress, frontend, storage, validator, ticker, systemKeyAccount);
      console.log(txScript);
    }
    const newCtlAddress = await script.getController();
    console.log("new controller: ", newCtlAddress);
    // ClaimOwnership 
    if (startAt <= 3) {
      console.log(`#3 ClaimOwnership of Token (${frontend}):`)
      const tx3 = await token.claimOwnership();
      console.log(tx3)
    }
    if (startAt <= 4) {
      console.log(`#4 ClaimOwnership of controller (${newCtlAddress}):`)
      const newCtl = await SmartController.at(newCtlAddress);
      const tx4 = await newCtl.claimOwnership();
      console.log(tx4)
    }
    if (startAt <= 5) {
      console.log(`#5 ClaimOwnership of old controller (${ctlAddress}):`)
      const tx5 = await ctl.claimOwnership();
      console.log(tx5)
    }
    exit(0);
  } catch (e) {
    exit(e);
  }
};
