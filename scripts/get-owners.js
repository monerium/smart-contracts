// IMPORTS
var SmartController = artifacts.require("SmartController");
var BlacklistValidator = artifacts.require("BlacklistValidator");
var TokenFrontend = artifacts.require("TokenFrontend");
var TokenStorage = artifacts.require("TokenStorage");

module.exports = async function (exit) {
  if (process.argv.length < 5) {
    console.log(`Usage: ${process.argv.join(" ")} <token>`);
    exit(1);
  }

  const len = process.argv.length;
  const address = process.argv[len - 1];
  console.log(`token ${address}`);

  try {
    // GET INSTANCE
    const token = await TokenFrontend.at(address);
    const x = await token.getController();
    const controller = await SmartController.at(x);
    const s = await controller.getStorage();
    const storage = await TokenStorage.at(s);
    const v = await controller.getValidator();
    const validator = await BlacklistValidator.at(v);
    // GET OWNERS
    const tokenOwner = await token.owner();
    const controllerOwner = await controller.owner();
    const storageOwner = await storage.owner();
    const validatorOwner = await validator.owner();
    // PRINT
    console.log(`TokenFrontend(${address}) : ${tokenOwner}`);
    console.log(`Controller(${x}) : ${controllerOwner}`);
    console.log(`Storage(${s}) : ${storageOwner}`);
    console.log(`Validator(${v}) : ${validatorOwner}`);
    exit(0);
  } catch (e) {
    exit(e);
  }
};
