var truffleAssert = require("truffle-assertions");
var MintableController = artifacts.require("./MintableController.sol");

var EUR = artifacts.require("./EUR.sol");
var StandardController = artifacts.require("./StandardController.sol");
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var ERC677Lib = artifacts.require("./ERC677Lib.sol");
var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var TokenStorageLib = artifacts.require("./TokenStorageLib.sol");
var SmartController = artifacts.require("./SmartController.sol");
var StandardController = artifacts.require("./StandardController.sol");
var ConstantSmartController = artifacts.require(
  "./ConstantSmartController.sol"
);
var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");

var SmartTokenLib = artifacts.require("./SmartTokenLib.sol");
const AddressZero = "0x0000000000000000000000000000000000000000";

const wallet = {
  address: `0xFB7ce0578B4dc16803A3CB04fA0b286fCFfFF76d`,
  signature: `0x1e1769b8ca9ca3d7d4b747f15336c185aac391c89cd9b9bfaf26f0a38631690e64ccd925382278c055c527a58ffab853a9734d889a6bae2b920544645f8ce4361c`,
};

contract("SystemRole", (accounts) => {
  if (web3.version.network <= 100) {
    console.log("Skipping test on local network");
    return;
  }
  const ADMIN_ROLE =
    "0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775"; // SHA3("ADMIN_ROLE")
  const owner = accounts[0];
  const system = accounts[1];
  const admin = accounts[2];
  let controller;
  let eur;

  before("setup system role eure", async () => {
    // Link
    mintableTokenLib = await MintableTokenLib.new();
    smartTokenLib = await SmartTokenLib.new();
    tokenStorageLib = await TokenStorageLib.new();
    erc20Lib = await ERC20Lib.new();
    erc677Lib = await ERC677Lib.new();
    await SmartController.link("MintableTokenLib", mintableTokenLib.address);
    await SmartController.link("SmartTokenLib", smartTokenLib.address);
    await SmartController.link("TokenStorageLib", tokenStorageLib.address);
    await SmartController.link("ERC20Lib", erc20Lib.address);
    await SmartController.link("ERC677Lib", erc677Lib.address);

    await StandardController.link("TokenStorageLib", tokenStorageLib.address);
    await StandardController.link("ERC20Lib", erc20Lib.address);
    await StandardController.link("ERC677Lib", erc677Lib.address);

    await ConstantSmartController.link(
      "MintableTokenLib",
      mintableTokenLib.address
    );
    await ConstantSmartController.link("SmartTokenLib", smartTokenLib.address);
    await ConstantSmartController.link(
      "TokenStorageLib",
      tokenStorageLib.address
    );
    await ConstantSmartController.link("ERC20Lib", erc20Lib.address);
    await ConstantSmartController.link("ERC677Lib", erc677Lib.address);
    // Deploy
    eur = await EUR.new();
    validator = await BlacklistValidator.new();
    controller = await SmartController.new(
      AddressZero,
      validator.address,
      web3.utils.asciiToHex("EUR"),
      eur.address
    );
    await eur.setController(controller.address);
    await controller.addAdminAccount(admin);
    await controller.addSystemAccount(system);
  });

  it("owner should be able to add system account", async () => {
    await controller.addSystemAccount(wallet.address, { from: owner });
    const result = await controller.isSystemAccount(wallet.address);
    assert.equal(result, true, "system account was not added");
  });

  it("owner should be able to remove system account", async () => {
    await controller.removeSystemAccount(wallet.address, { from: owner });
    const result = await controller.isSystemAccount(wallet.address);
    assert.equal(result, false, "system account was not removed");
  });

  it("owner should be able to add admin account", async () => {
    await controller.addAdminAccount(wallet.address, { from: owner });
    const result = await controller.hasRole(ADMIN_ROLE, wallet.address);
    assert.equal(result, true, "admin account was not added");
  });

  it("owner should be able to remove admin account", async () => {
    await controller.removeAdminAccount(wallet.address, { from: owner });
    const result = await controller.hasRole(ADMIN_ROLE, wallet.address);
    assert.equal(result, false, "admin account was not removed");
  });

  it("owner should be able to set the maximum a system account can allow to mint", async () => {
    await controller.setMaxMintAllowance(100, { from: owner });
    const result = await controller.getMaxMintAllowance();
    assert.equal(result, 100, "max mint amount was not set");
  });

  it("non-owner should not be able to set the maximum a system account can allow to mint", async () => {
    await truffleAssert.reverts(
      controller.setMaxMintAllowance(100, { from: system })
    );
    await truffleAssert.reverts(
      controller.setMaxMintAllowance(100, { from: admin })
    );
  });

  it("owner should not be able to set mintAllowance", async () => {
    await truffleAssert.reverts(
      controller.setMintAllowance(system, 100, { from: owner })
    );
  });

  it("system should not be able to set mintAllowance", async () => {
    await truffleAssert.reverts(
      controller.setMintAllowance(system, 100, { from: system })
    );
  });

  it("admin should not be able to set above max mint amount", async () => {
    await truffleAssert.reverts(
      controller.setMintAllowance(system, 101, { from: admin })
    );
  });

  it("admin should be able to set mintAllowance", async () => {
    await controller.setMintAllowance(system, 100, { from: admin });
    const result = await controller.getMintAllowance(system);
    assert.equal(result, 100, "mint allowance was not set");
  });

  it("system should be able to mint within allowances", async () => {
    await eur.mintTo(wallet.address, 99, {
      from: system,
    })
    const result = await controller.balanceOf(wallet.address);
    assert.equal(result, 99, "minting within allowances was not succesfull");
  });

  it("system should not be able to mint above allowances", async () => {
    const remaningAllowances = await controller.getMintAllowance(system);
    await truffleAssert.reverts(
      eur.mintTo(
        wallet.address,
        remaningAllowances + 10,
        { from: system }
      )
    );
  });

  it("non-system with allowances should not be able to mint", async () => {
    await controller.setMintAllowance(admin, 100, { from: admin });
    const remaningAllowances = await controller.getMintAllowance(admin);
    assert.equal(remaningAllowances, 100, "mint allowance was not set");
    await truffleAssert.reverts(
      eur.mintTo(wallet.address, 100, { from: admin })
    );
  });

  it("should be able to add system account after transfering ownerhsip", async () => {
    await controller.transferOwnership(system, { from: owner });
    await controller.claimOwnership({ from: system });
    const newOwner = await controller.owner();
    assert.equal(newOwner, system, "ownership was not transfered");

    await controller.addSystemAccount(admin, { from: system });
    const result = await controller.isSystemAccount(admin);
    assert.equal(result, true, "system account was not added");
  });
});
