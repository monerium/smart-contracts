var TokenFrontend = artifacts.require("./TokenFrontend.sol");
var SmartController = artifacts.require("./SmartController.sol");

module.exports = async function (exit) {
  if (process.argv.length < 5) {
    console.log(`Usage: ${process.argv.join(" ")} <token_frontend_address>`);
    exit(1);
  }

  const len = process.argv.length;
  const frontendAddress = process.argv[len - 1];
  console.log(`Fetching controller from frontend address ${frontendAddress}`);

  try {
    const tokenFrontend = await TokenFrontend.at(frontendAddress);
    const controllerAddress = await tokenFrontend.getController();
    const bytecode = await web3.eth.getCode(controllerAddress);
    const bytecodeHash = web3.utils.sha3(bytecode);
    console.log(`Controller address: ${controllerAddress}`);
    console.log(`Controller bytecode hash: ${bytecodeHash}`);
    exit(0);
  } catch (e) {
    console.error(`Error fetching bytecode: ${e}`);
    exit(e);
  }
};
