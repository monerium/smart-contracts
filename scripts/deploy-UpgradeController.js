const UpgradeController = artifacts.require("UpgradeController");
const MintableTokenLib = artifacts.require("MintableTokenLib");
const TokenStorageLib = artifacts.require("TokenStorageLib");
const SmartTokenLib = artifacts.require("SmartTokenLib");
const ERC20Lib = artifacts.require("ERC20Lib");
const ERC677Lib = artifacts.require("ERC677Lib");
const SignatureChecker = artifacts.require("SignatureChecker");

module.exports = async function (exit) {
  try {
    // Deploying and Printing Libraries
    var tokenStorageLib = await deployAndLog(
      TokenStorageLib,
      "TokenStorageLib"
    );
    var erc20Lib = await deployAndLog(ERC20Lib, "ERC20Lib");
    ERC677Lib.link("ERC20Lib", erc20Lib.address);
    var erc677Lib = await deployAndLog(ERC677Lib, "ERC677Lib");
    var signatureChecker = await deployAndLog(
      SignatureChecker,
      "SignatureChecker"
    );

    MintableTokenLib.link("SignatureChecker", signatureChecker.address);
    var mintableTokenLib = await deployAndLog(
      MintableTokenLib,
      "MintableTokenLib"
    );

    // Linking
    SmartTokenLib.link("ERC20Lib", erc20Lib.address);
    SmartTokenLib.link("SignatureChecker", signatureChecker.address);
    SmartTokenLib.link("MintableTokenLib", mintableTokenLib.address);
    var smartTokenLib = await deployAndLog(SmartTokenLib, "SmartTokenLib");

    // Linking to UpgradeController
    await UpgradeController.link("SmartTokenLib", smartTokenLib.address);
    await UpgradeController.link("TokenStorageLib", tokenStorageLib.address);
    await UpgradeController.link("ERC20Lib", erc20Lib.address);
    await UpgradeController.link("ERC677Lib", erc677Lib.address);
    await UpgradeController.link("MintableTokenLib", mintableTokenLib.address);

    // Controller
    const instance = await deployAndLog(UpgradeController, "Upgrader");
    console.log(
      "\nPlease copy the logged addresses above for future use in contract validation and launching the upgrader."
    );
    exit(0);
  } catch (e) {
    exit(e);
  }
};

async function deployAndLog(Lib, name) {
  process.stdout.write("Deploying " + name);
  const instance = await Lib.new();
  console.log("@" + instance.address);
  return instance;
}
