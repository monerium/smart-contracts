const SmartController = artifacts.require("./SmartController.sol");
const TokenFrontend = artifacts.require("./TokenFrontend.sol");
const NewControllerAndBridgeFrontend = artifacts.require("./NewControllerAndBridgeFrontend.sol");

module.exports = async function(exit) {
  if (process.argv.length < 6) {
    console.log(`Usage: ${process.argv.join(" ")} <target frontend> <script contract>`)
    exit(1);
  }

  const len = process.argv.length;
  const frontend = process.argv[len - 2];
  const scriptContract = process.argv[len - 1];


  try {
    // Parameters
    const token = await TokenFrontend.at(frontend)
    const ctlAddress = await token.getController();
    const ctl = await SmartController.at(ctlAddress);
    const storage = await ctl.getStorage();
    const validator = await ctl.getValidator();
    const ticker = await ctl.ticker();
    const script = await NewControllerAndBridgeFrontend.at(scriptContract);

    const txScript = await script.launch(ctlAddress, frontend, storage, validator, ticker);
    console.log("tx: ", txScript);
    const bridge = await script.getBridge();
    const newCtl = await script.getController();
    console.log("new controller: ", newCtl, " ; new bridge frontend: ", bridge);
    exit(0);
  } catch (e) {
    exit(e);
  }
};
