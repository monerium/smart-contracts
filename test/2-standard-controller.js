var truffleAssert = require("truffle-assertions");
var StandardController = artifacts.require("./StandardController.sol");
var TokenStorage = artifacts.require("./TokenStorage.sol");
var AcceptingRecipient = artifacts.require("./AcceptingRecipient.sol");
var RejectingRecipient = artifacts.require("./RejectingRecipient.sol");
var SimpleToken = artifacts.require("./SimpleToken.sol");
var TokenStorage = artifacts.require("./TokenStorage.sol");
var USD = artifacts.require("./USD.sol");

var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var SmartTokenLib = artifacts.require("./SmartTokenLib.sol");
var TokenStorageLib = artifacts.require("./TokenStorageLib.sol");
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var ERC677Lib = artifacts.require("./ERC677Lib.sol");

const AddressZero = "0x0000000000000000000000000000000000000000";

contract("StandardController", (accounts) => {
  if (web3.version.network <= 100) return;

  const owner = accounts[0];
  let controller;

  before("setup standard controller", async () => {
    // Link
    tokenStorageLib = await TokenStorageLib.new();
    erc20Lib = await ERC20Lib.new();
    erc677Lib = await ERC677Lib.new();
    await StandardController.link("TokenStorageLib", tokenStorageLib.address);
    await StandardController.link("ERC20Lib", erc20Lib.address);
    await StandardController.link("ERC677Lib", erc677Lib.address);
    await TokenStorage.link("TokenStorageLib", TokenStorageLib.address);
    // Deploy
    frontend = await USD.new();
    controller = await StandardController.new(
      AddressZero,
      50000,
      frontend.address
    );
  });

  it("should construct with TokenStorage as constructor", async () => {
    storage = await TokenStorage.new();
    controller2 = await StandardController.new(storage.address, 0, AddressZero);

    controllerStorage = await controller2.getStorage();
    assert.equal(
      storage.address,
      controllerStorage,
      "The controller's storage isn't the same as given in construction's argument"
    );
  });

  it("should have a total supply of 50000 tokens", async () => {
    const supply = await controller.totalSupply();
    assert.equal(supply.valueOf(), 50000, "The total supply isn't 50000");
  });

  it("should put 50000 tokens in the first account", async () => {
    const balance = await controller.balanceOf(accounts[0]);
    assert.equal(balance.valueOf(), 50000, "50000 wasn't in the first account");
  });

  it("should be able to change ownership of its storage", async () => {
    const storage = await TokenStorage.at(await controller.getStorage());
    const owner0 = await storage.owner();
    assert.strictEqual(owner0, controller.address, "incorrect original owner");
    await controller.transferStorageOwnership(accounts[0]);
    await storage.claimOwnership({ from: accounts[0] });
    const owner1 = await storage.owner();
    assert.strictEqual(
      owner1,
      accounts[0],
      "unable to transfer/claim ownership"
    );
    await storage.transferOwnership(controller.address);
    await controller.claimStorageOwnership();
    const owner2 = await storage.owner();
    assert.strictEqual(
      owner2,
      owner0,
      "controller should be the storage owner"
    );
  });

  it("should fail to set a new storage from a non-owner account", async () => {
    const initial = await controller.getStorage();
    const storage = await TokenStorage.new();
    assert.notEqual(
      storage.address,
      initial,
      "initial storage should not be a newly instantiated storage"
    );
    await truffleAssert.reverts(
      controller.setStorage(storage.address, { from: accounts[7] })
    );
    const post = await controller.getStorage();
    assert.strictEqual(post, initial, "storage should not change");
  });

  it("should be able to set a new storage from an owner account", async () => {
    const initial = await controller.getStorage();
    const storage = await TokenStorage.new();
    assert.notEqual(
      storage.address,
      initial,
      "initial storage should not be a newly instantiated storage"
    );
    await controller.setStorage(storage.address, { from: owner });
    const post = await controller.getStorage();
    assert.strictEqual(post, storage.address, "storage did not change");
  });

  it("should fail to set the frontend as a non-owner", async () => {
    const initial = await controller.getFrontend();
    const frontend = await USD.new();
    assert.notEqual(
      frontend.address,
      initial,
      "initial frontend should not be a newly instantiated frontend"
    );
    await truffleAssert.reverts(
      controller.setFrontend(frontend.address, { from: accounts[9] })
    );
    const post = await controller.getFrontend();
    assert.strictEqual(post, initial, "frontend should not change");
  });

  it("should be able to set the frontend as an owner", async () => {
    const initial = await controller.getFrontend();
    const frontend = await USD.new();
    assert.notEqual(
      frontend.address,
      initial,
      "initial frontend should not be a newly instantiated frontend"
    );
    await controller.setFrontend(frontend.address, { from: owner });
    const post = await controller.getFrontend();
    assert.strictEqual(post, frontend.address, "frontend did not change");
  });
});
