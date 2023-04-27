const SmartController = artifacts.require("./SmartController.sol");
const TokenFrontend = artifacts.require("./TokenFrontend.sol");

module.exports = async function(exit) {
  if (process.argv.length < 7) {
    console.log(`Usage: ${process.argv.join(" ")} <target frontend> <bridge frontend>`)
    exit(1);
  }

  const len = process.argv.length;
  const frontend = process.argv[len - 2];
  const bridge = process.argv[len - 1];

  try {
    // Parameters
    const token = await TokenFrontend.at(frontend)
    const tokenBridge = await TokenFrontend.at(bridge)
    const ctlAddress = await token.getController();
    const ctl = await SmartController.at(ctlAddress);
    console.log (`Claiming ownership of token:`, token.address, " and controller: ", ctlAddress);
    txToken = await token.claimOwnership();
    txController = await ctl.claimOwnership();
    txBridge = await tokenBridge.claimOwnership();
    console.log("token tx :", txToken, "\nController tx: ", txController, "\nBridge tx: ", txBridge);
    exit(0);
  } catch (e) {
    exit(e);
  }
};
