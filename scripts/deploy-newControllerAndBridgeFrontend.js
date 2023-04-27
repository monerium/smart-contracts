const NewControllerAndBridgeFrontend = artifacts.require(
  "./newControllerAndBridgeFrontend.sol"
);
const MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
const TokenStorageLib = artifacts.require("./TokenStorageLib.sol");
const SmartTokenLib = artifacts.require("./SmartTokenLib.sol");
const ERC20Lib = artifacts.require("./ERC20Lib.sol");
const ERC677Lib = artifacts.require("./ERC677Lib.sol");
const SafeMathLib = artifacts.require("zeppelin-solidity/math/SafeMath.sol");

module.exports = async function (exit) {
  // Libraries
  var safeMathLib;
  var smartTokenLib;
  var erc20Lib;
  var erc677Lib;
  var mintableTokenLib;
  var tokenStorageLib;

  try {
    // Libraries
    if (SafeMathLib.isDeployed() == false) {
      console.log("SafeMathLib missing, deploying...");
      safeMathLib = await SafeMathLib.new();
      TokenStorageLib.link("SafeMathLib", safeMathLib.address);
      ERC20Lib.link("SafeMathLib", safeMathLib.address);
      MintableTokenLib.link("SafeMathLib", safeMathLib.address);
      console.log("SafeMathLib: ", safeMathLib.address);
    } else {
      safeMathLib = await SafeMathLib.at(SafeMathLib.address);
    }
    if (TokenStorageLib.isDeployed() == false) {
      console.log("TokenStorageLib missing, deploying...");
      tokenStorageLib = await TokenStorageLib.new();
      console.log("TokenStorageLib: ", tokenStorageLib.address);
    } else {
      tokenStorageLib = await TokenStorageLib.at(TokenStorageLib.address);
    }
    if (ERC20Lib.isDeployed() == false) {
      console.log("ERC20Lib missing, deploying...");
      erc20Lib = await ERC20Lib.new();
      SmartTokenLib.link("ERC20Lib", erc20Lib.address);
      ERC677Lib.link("ERC20Lib", erc20Lib.address);
      console.log("ERC20Lib: ", erc20Lib.address);
    } else {
      erc20Lib = await ERC20Lib.at(ERC20Lib.address);
    }
    if (ERC677Lib.isDeployed() == false) {
      console.log("ERC677Lib missing, deploying...");
      erc677Lib = await ERC677Lib.new();
      console.log("ERC677Lib: ", erc677Lib.address);
    } else {
      erc677Lib = await ERC677Lib.at(ERC677Lib.address);
    }
    if (MintableTokenLib.isDeployed() == false) {
      console.log("MintableTokenLib missing, deploying...");
      mintableTokenLib = await MintableTokenLib.new();
      SmartTokenLib.link("MintableTokenLib", mintableTokenLib.address);
      console.log("MintableTokenLib: ", mintableTokenLib.address);
    } else {
      mintableTokenLib = await MintableTokenLib.at(MintableTokenLib.address);
    }
    if (SmartTokenLib.isDeployed() == false) {
      console.log("SmartTokenLib missing, deploying...");
      smartTokenLib = await SmartTokenLib.new();
      console.log("SmartTokenLib: ", smartTokenLib.address);
    } else {
      smartTokenLib = await SmartTokenLib.at(SmartTokenLib.address);
    }
    await NewControllerAndBridgeFrontend.link(
      "SmartTokenLib",
      smartTokenLib.address
    );
    await NewControllerAndBridgeFrontend.link(
      "TokenStorageLib",
      tokenStorageLib.address
    );
    await NewControllerAndBridgeFrontend.link("ERC20Lib", erc20Lib.address);
    await NewControllerAndBridgeFrontend.link("ERC677Lib", erc677Lib.address);
    await NewControllerAndBridgeFrontend.link(
      "MintableTokenLib",
      mintableTokenLib.address
    );
    //Controller
    const instance = await NewControllerAndBridgeFrontend.new();
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
