const UpgradeController = artifacts.require("UpgradeController");
const MintableTokenLib = artifacts.require("MintableTokenLib");
const TokenStorageLib = artifacts.require("TokenStorageLib");
const SmartTokenLib = artifacts.require("SmartTokenLib");
const ERC20Lib = artifacts.require("ERC20Lib");
const ERC677Lib = artifacts.require("ERC677Lib");
const SafeMathLib = artifacts.require("zeppelin-solidity/math/SafeMath");
const SignatureChecker = artifacts.require("SignatureChecker");

module.exports = async function (exit) {
  // Libraries
  var safeMathLib;
  var smartTokenLib;
  var erc20Lib;
  var erc677Lib;
  var mintableTokenLib;
  var tokenStorageLib;
  var signatureChecker;

  try {
    // Libraries
      safeMathLib = await SafeMathLib.at("0xBD3bC30FF6D8901091e6039457067091BCB52fC7");
    TokenStorageLib.link("SafeMathLib", safeMathLib.address);
    ERC20Lib.link("SafeMathLib", safeMathLib.address);
    MintableTokenLib.link("SafeMathLib", safeMathLib.address);
    console.log("SafeMathLib: ", safeMathLib.address);
      tokenStorageLib = await TokenStorageLib.at("0x5069aa7213E58ceD87CBBca6b1154085238916d2");
    console.log("TokenStorageLib: ", tokenStorageLib.address);
      erc20Lib = await ERC20Lib.at("0xf2170b528E575e22849E5922c7f1441755AD2443");
    SmartTokenLib.link("ERC20Lib", erc20Lib.address);
    ERC677Lib.link("ERC20Lib", erc20Lib.address);
    console.log("ERC20Lib: ", erc20Lib.address);
      erc677Lib = await ERC677Lib.at("0x2b61A324D557F057e94F5D4A9c64824c6f7c9af7");
    console.log("ERC677Lib: ", erc677Lib.address);
      signatureChecker = await SignatureChecker.at("0x40a02567572E2Be64b20f9696fde9B5638eB5894");
    SmartTokenLib.link("SignatureChecker", signatureChecker.address);
    MintableTokenLib.link("SignatureChecker", signatureChecker.address);
    console.log("SignatureChecker: ", signatureChecker.address);
      mintableTokenLib = await MintableTokenLib.at("0x85B4CeFb40dd9bF66CE5820D8081E8be2Be82661");
    SmartTokenLib.link("MintableTokenLib", mintableTokenLib.address);
    console.log("MintableTokenLib: ", mintableTokenLib.address);
      smartTokenLib = await SmartTokenLib.at("0xD1e12192b50b4D3fF3A09CFa0FC1fa8E821de8Ff");
    console.log("SmartTokenLib: ", smartTokenLib.address);

    await UpgradeController.link("SmartTokenLib", smartTokenLib.address);
    await UpgradeController.link("TokenStorageLib", tokenStorageLib.address);
    await UpgradeController.link("ERC20Lib", erc20Lib.address);
    await UpgradeController.link("ERC677Lib", erc677Lib.address);
    await UpgradeController.link("MintableTokenLib", mintableTokenLib.address);
    //Controller
    const instance = await UpgradeController.new();
    console.log(
      "Contract deployed to: ",
      instance.address,
      " tx: ",
      instance.transactionHash
    );
    exit(0);
  } catch (e) {
    exit(e);
  }
};
