const SmartController = artifacts.require("SmartController");
const MintableTokenLib = artifacts.require("MintableTokenLib");
const TokenStorageLib = artifacts.require("TokenStorageLib");
const SmartTokenLib = artifacts.require("SmartTokenLib");
const ERC20Lib = artifacts.require("ERC20Lib");
const EUR = artifacts.require("EUR");
const ERC677Lib = artifacts.require("ERC677Lib");
const SignatureChecker = artifacts.require("SignatureChecker");
const BlacklistValidator = artifacts.require("BlacklistValidator");

module.exports = async function (exit) {
  const AddressZero = "0x0000000000000000000000000000000000000000";
  try {
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
    await SmartController.link("SmartTokenLib", smartTokenLib.address);
    await SmartController.link("TokenStorageLib", tokenStorageLib.address);
    await SmartController.link("ERC20Lib", erc20Lib.address);
    await SmartController.link("ERC677Lib", erc677Lib.address);
    await SmartController.link("MintableTokenLib", mintableTokenLib.address);

    var eur = await deployAndLog(EUR, "EUR");
    var validator = await deployAndLog(
      BlacklistValidator,
      "BlacklistValidator"
    );
    var ctrl = await SmartController.new(
      AddressZero,
      validator.address,
      web3.utils.asciiToHex("EUR"),
      eur.address
    );
    console.log("Deployed SmartController@ " + ctrl.address);
    await eur.setController(ctrl.address);
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
