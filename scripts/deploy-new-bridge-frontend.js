const EUR = artifacts.require("./EUR.sol");
const SmartController = artifacts.require("./SmartController.sol");

module.exports = async function(exit) {
  if (process.argv.length < 7) {
    console.log(`Usage: ${process.argv.join(" ")} <default frontend> <bridge name>`)
    exit(1);
  }
  const len = process.argv.length;
  const frontend = process.argv[len - 2];
  const bridgeName = process.argv[len - 1];

  try {
    // #1 Deploy the new frontend.
    const bridge = await EUR.new();
    console.log("Contract deployed to: ", bridge.address, " tx: ", bridge.transactionHash);
    // #2 Instantiate the controller.
    const defaultFrontend = await EUR.at(frontend);
    const controllerAddress = await defaultFrontend.getController();
    const controller = await SmartController.at(controllerAddress);
    // #3 Register the new frontend as a frontend bridge.
    const registerBridgeTx = await controller.setBridgeFrontend(bridge.address, bridgeName)
    console.log("Registering new frontend as frontend bridge. tx: ", registerBridgeTx)
    // #4 Register the controller in the new frontend.
    const registerControllerTx = await bridge.setController(controllerAddress);
    console.log("Registering the controller in the bridge frontend. tx: ", registerControllerTx);
    exit(0);
  } catch (e) {
    exit(e);
  }
};
