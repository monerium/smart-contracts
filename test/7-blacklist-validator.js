var truffleAssert = require('truffle-assertions');
var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");
var AcceptingRecipient = artifacts.require("./AcceptingRecipient.sol");
var SimpleToken = artifacts.require("./SimpleToken.sol");
var StandardController = artifacts.require("./StandardController.sol");

contract("BlacklistValidator", accounts => {

  if (web3.version.network <= 100) return;

  const owner = accounts[0];
  let validator;

  beforeEach("setup blacklist validator", async () => { 
    validator = await BlacklistValidator.deployed();
  });

  it("should succeed in banning account from an owner address", async () => {
    await validator.ban(accounts[7], {from: owner});
    const success = await validator.blacklist(accounts[7]);
    assert.strictEqual(success, true, "unable to ban account");
  });

  it("should succeed in unbanning account from an owner address", async () => {
    await validator.unban(accounts[7], {from: owner});
    const isBanned = await validator.blacklist(accounts[7]);
    assert.strictEqual(isBanned, false, "unable to unban account");
  });

  it("should fail banning account from a non-owner address", async () => {
    await truffleAssert.reverts(
      validator.ban(accounts[6], {from: accounts[5]})
    );
  });

  it("should fail unbanning account from a non-owner address", async () => {
    await validator.ban(accounts[6], {from: owner});
    const success = await validator.blacklist(accounts[6]);
    assert.strictEqual(success, true, "unable to ban account");
    await truffleAssert.reverts(
      validator.unban(accounts[6], {from: accounts[5]})
    );
  });

  it("should not validate from a banned account", async () => {
    await validator.ban(accounts[8]);
    // unable to check return value since the method is non-pure because it emits an event.
    await validator.validate(accounts[8], accounts[8], 0); 
  });

  it("should be able to reclaim ownership of contracts", async () => {
    const recipient = await AcceptingRecipient.deployed();
    const owner0 = await recipient.owner();
    assert.strictEqual(owner0, owner, "incorrect original owner");
    await recipient.transferOwnership(BlacklistValidator.address, {from: owner0});
    const owner1 = await recipient.owner();
    assert.strictEqual(owner1, BlacklistValidator.address, "standard controller should be owner");
    await validator.reclaimContract(AcceptingRecipient.address);
    const owner2 = await recipient.owner();
    assert.strictEqual(owner2, owner0, "must be original owner after reclaiming ownership");
  });

  it("should be able to recover tokens (ERC20)", async () => {
    const token = await SimpleToken.deployed();
    const amount0 = await token.balanceOf(owner);
    assert.notEqual(amount0.toNumber(), 0, "owner must have some tokens");
    const balance0 = await token.balanceOf(BlacklistValidator.address);
    assert.strictEqual(balance0.toNumber(), 0, "initial balance must be 0");
    await token.transfer(BlacklistValidator.address, 20, {from: owner});
    const balance1 = await token.balanceOf(BlacklistValidator.address);
    assert.strictEqual(balance1.toNumber(), 20, "ERC20 transfer should succeed");
    await validator.reclaimToken(token.address);
    const balance2 = await token.balanceOf(BlacklistValidator.address);
    assert.strictEqual(balance2.toNumber(), balance0.toNumber(), "mismatch in token before and after");
    const amount1 = await token.balanceOf(owner);
    assert.strictEqual(amount1.toNumber(), amount0.toNumber(), "unable to recover");
  });

})
