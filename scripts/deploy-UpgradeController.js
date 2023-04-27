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
    if (true || SafeMathLib.isDeployed() == false) {
      console.log("SafeMathLib missing, deploying...");
      safeMathLib = await SafeMathLib.new();
    } else {
      safeMathLib = await SafeMathLib.at(SafeMathLib.address);
    }
    TokenStorageLib.link("SafeMathLib", safeMathLib.address);
    ERC20Lib.link("SafeMathLib", safeMathLib.address);
    MintableTokenLib.link("SafeMathLib", safeMathLib.address);
    console.log("SafeMathLib: ", safeMathLib.address);
    if (true || TokenStorageLib.isDeployed() == false) {
      console.log("TokenStorageLib missing, deploying...");
      tokenStorageLib = await TokenStorageLib.new();
    } else {
      tokenStorageLib = await TokenStorageLib.at(TokenStorageLib.address);
    }
    console.log("TokenStorageLib: ", tokenStorageLib.address);
    if (true || ERC20Lib.isDeployed() == false) {
      console.log("ERC20Lib missing, deploying...");
      erc20Lib = await ERC20Lib.new();
    } else {
      erc20Lib = await ERC20Lib.at(ERC20Lib.address);
    }
    SmartTokenLib.link("ERC20Lib", erc20Lib.address);
    ERC677Lib.link("ERC20Lib", erc20Lib.address);
    console.log("ERC20Lib: ", erc20Lib.address);
    if (true || ERC677Lib.isDeployed() == false) {
      console.log("ERC677Lib missing, deploying...");
      erc677Lib = await ERC677Lib.new();
    } else {
      erc677Lib = await ERC677Lib.at(ERC677Lib.address);
    }
    console.log("ERC677Lib: ", erc677Lib.address);
    if (true || SignatureChecker.isDeployed() == false) {
      console.log("SignatureChecker missing, deploying...");
      signatureChecker = await SignatureChecker.new();
    } else {
      signatureChecker = await SignatureChecker.at(SignatureChecker.address);
    }
    SmartTokenLib.link("SignatureChecker", signatureChecker.address);
    MintableTokenLib.link("SignatureChecker", signatureChecker.address);
    console.log("SignatureChecker: ", signatureChecker.address);
    if (true || MintableTokenLib.isDeployed() == false) {
      console.log("MintableTokenLib missing, deploying...");
      mintableTokenLib = await MintableTokenLib.new();
    } else {
      mintableTokenLib = await MintableTokenLib.at(MintableTokenLib.address);
    }
    SmartTokenLib.link("MintableTokenLib", mintableTokenLib.address);
    console.log("MintableTokenLib: ", mintableTokenLib.address);
    if (true || SmartTokenLib.isDeployed() == false) {
      console.log("SmartTokenLib missing, deploying...");
      smartTokenLib = await SmartTokenLib.new();
    } else {
      smartTokenLib = await SmartTokenLib.at(SmartTokenLib.address);
    }
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
