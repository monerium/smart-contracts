var truffleAssert = require("truffle-assertions");
var TokenStorage = artifacts.require("./TokenStorage.sol");
var AcceptingRecipient = artifacts.require("./AcceptingRecipient.sol");
var SimpleToken = artifacts.require("./SimpleToken.sol");
var StandardController = artifacts.require("./StandardController.sol");

var TokenStorageLib = artifacts.require("./TokenStorageLib.sol");

contract("TokenStorage", accounts => {

  if (web3.version.network <= 100) return;

  let storage;

  before("setup storage", async () => {
    tokenStorageLib = await TokenStorageLib.new();
    await TokenStorage.link("TokenStorageLib", tokenStorageLib.address);
    storage = await TokenStorage.new();
  });

  it("should not have initial supply", async () => {
    const supply = await storage.getSupply();
    assert.equal(supply.valueOf(), 0, "total supply is not 0");
  });

  it("should have a supply of 85000 after manually increasing to 85000", async () => {
    await storage.addBalance(accounts[0], 85000);
    const supply = await storage.getSupply();
    assert.equal(supply.valueOf(), 85000, "total supply is not 85000");
  });

  it("should have a supply of 73000 after explicitly reducing from 85000", async () => {
    await storage.subBalance(accounts[0], 12000);
    const supply = await storage.getSupply();
    assert.equal(supply.valueOf(), 73000, "total supply is not 73000");
  });

  it("should have a cumulative balance of 73000 in the first account", async () => {
    const balance = await storage.getBalance(accounts[0]);
    assert.equal(balance.valueOf(), 73000, "balance in account one is not 73000");
  });

  it("should have a balance of 30000 in second account", async () => {
    await storage.addBalance(accounts[1], 30000);
    const balance = await storage.getBalance(accounts[1]);
    assert.equal(balance.valueOf(), 30000, "balance is not 30000");
  });

  it("should fail when minting from a non-owner account", async () => {
    await truffleAssert.reverts(
      storage.addBalance(accounts[3], 1000000, {from: accounts[4]})
    );
  });

  it("should be able to reclaim ownership of contracts", async () => {
    const recipient = await AcceptingRecipient.new()
    const owner0 = await recipient.owner();
    assert.strictEqual(owner0, accounts[0], "incorrect original owner");
    await recipient.transferOwnership(storage.address, {from: owner0});
    const owner1 = await recipient.owner();
    assert.strictEqual(owner1, storage.address, "standard controller should be owner");
    await storage.reclaimContract(recipient.address);
    const owner2 = await recipient.owner();
    assert.strictEqual(owner2, owner0, "must be original owner after reclaiming ownership");
  });

  it("should be able to recover tokens (ERC20)", async () => {
    const token = await SimpleToken.new();
    const amount0 = await token.balanceOf(accounts[0]);
    assert.notEqual(amount0.toNumber(), 0, "owner must have some tokens");
    const balance0 = await token.balanceOf(storage.address);
    assert.strictEqual(balance0.toNumber(), 0, "initial balance must be 0");
    await token.transfer(storage.address, 20, {from: accounts[0]});
    const balance1 = await token.balanceOf(storage.address);
    assert.strictEqual(balance1.toNumber(), 20, "ERC20 transfer should succeed");
    await storage.reclaimToken(token.address);
    const balance2 = await token.balanceOf(storage.address);
    assert.strictEqual(balance2.toNumber(), balance0.toNumber(), "mismatch in token before and after");
    const amount1 = await token.balanceOf(accounts[0]);
    assert.strictEqual(amount1.toNumber(), amount0.toNumber(), "unable to recover");
  });

  it("should be able to transfer ownership", async () => {
    const owner0 = await storage.owner();
    assert.strictEqual(owner0, accounts[0], "incorrect original owner");

    await storage.transferOwnership(accounts[8], {from: owner0});
    const owner1 = await storage.owner();
    assert.strictEqual(owner1, owner0, "must be original owner before claiming ownership");

    await storage.claimOwnership({from: accounts[8]});
    const owner2 = await storage.owner();
    assert.strictEqual(owner2, accounts[8], "must be new owner address after claiming ownership");
  });

});
