const { SigningKey } = require("@ethersproject/signing-key");
const truffleAssert = require("truffle-assertions");

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
  address: `0x77a3373AdCBe91E589D54F3a92Bb3F73F56686F4`,
  privateKey: `0x1a2a4798d8b0e070ceee86d09e0942ad489919450cda74d9ed4d9b90d0a3173a`,
};

contract("PausableController", (accounts) => {
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
  let mintableTokenLib;
  let smartTokenLib;
  let tokenStorageLib;
  let erc20Lib;
  let erc677Lib;
  let validator;

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
    await controller.setMaxMintAllowance(1000000000000);
    await controller.setMintAllowance(system, 1000000000000, {
      from: admin,
    });
  });

  it("should mint 74000 new tokens", async () => {
    await eur.mintTo(system, 74000, { from: system });
    const balance = await eur.balanceOf(system);
    assert.equal(balance.valueOf(), 74000, "did not mint 74000 tokens");
  });

  it("should transfer 7200 tokens to second account", async () => {
    await eur.transfer(accounts[0], 7200, { from: system });
    const balance = await eur.balanceOf(accounts[0]);
    assert.equal(balance.valueOf(), 7200, "did not transfer 7200 tokens");
  });

  it("should allow the third account to spend 9600 from the first account", async () => {
    await eur.transfer(accounts[0], 9600, { from: system });
    await eur.approve(accounts[2], 10600, { from: accounts[0] });
    const allowance = await eur.allowance(accounts[0], accounts[2]);
    assert.equal(allowance.valueOf(), 10600, "the allowance wasn't 9600");
  });

  it("should transfer 9300 from the first account to the fourth using the third account", async () => {
    await eur.transferFrom(accounts[0], accounts[3], 9600, {
      from: accounts[2],
    });
    const balance = await eur.balanceOf(accounts[3]);
    assert.equal(
      balance.valueOf(),
      9600,
      "The forth account does not have 9600"
    );
  });

  it("should pause the contract", async () => {
    await controller.pause({ from: owner });
    const paused = await controller.paused();
    assert.equal(paused, true, "The contract was not paused");
  });

  it("should not allow the contract to mint new tokens", async () => {
    await truffleAssert.reverts(
      eur.mintTo(accounts[0], 1000, { from: system })
    );
  });

  it("should not allow the contract to transfer tokens", async () => {
    await truffleAssert.reverts(
      eur.transfer(accounts[0], 1000, { from: system })
    );
  });

  it("should not allow the contract to transfer tokens from another account", async () => {
    await truffleAssert.reverts(
      eur.transferFrom(accounts[0], accounts[3], 1000, { from: accounts[2] })
    );
  });
});
