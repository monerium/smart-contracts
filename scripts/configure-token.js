var SmartController = artifacts.require("./SmartController.sol");
var TokenFrontend = artifacts.require("./TokenFrontend.sol");

module.exports = async function (exit) {
  if (process.argv.length < 7) {
    console.log(`Usage: ${process.argv.join(" ")} <token> <system> <admin> [allowance]`);
    exit(1);
  }

  const len = process.argv.length;
  const address = process.argv[len - 4];
  const system = process.argv[len - 3];
  const admin = process.argv[len - 2];
  let allowance = process.argv[len - 1];
  if (!allowance) {
    allowance = "50000000000000000000000000";
  }

  console.log(`Configuring with Token: ${address}, System: ${system}, Admin: ${admin}, Allowance: ${allowance}`);

  try {
    const token = await TokenFrontend.at(address);
    const owner = await token.owner();
    const x = await token.getController();
    const controller = await SmartController.at(x);
    
    await controller.addAdminAccount(admin);
    console.log("Admin account added successfully.");

    await controller.addSystemAccount(system);
    console.log("System account added successfully.");

    await controller.setMaxMintAllowance(allowance);
    console.log("Max mint allowance set successfully.");

    if (admin == owner) {
      await controller.setMintAllowance(system, allowance);
      console.log("Mint allowance set successfully for system as owner.");
    }

    exit(0);
  } catch (e) {
    console.error(e);
    exit(e);
  }
};
