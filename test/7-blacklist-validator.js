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
    validator = await BlacklistValidator.new();
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
    // we read the logs args to get the return value since the method is non-pure because it emits an event.
    const valid = await validator.validate(accounts[8], accounts[8], 0);
    assert.strictEqual(valid.logs[0].args['3'], false, "banned account is not valid");
  });

  it("should validate from a non-banned account", async () => {
    // we read the logs args to get the return value since the method is non-pure because it emits an event.
    const valid = await validator.validate(accounts[7], accounts[7], 0);
    assert.strictEqual(valid.logs[0].args['3'], true, "unbanned account is valid");
  });

  it("should be able to recover tokens (ERC20)", async () => {
    const token = await SimpleToken.new();
    const amount0 = await token.balanceOf(owner);
    assert.notEqual(amount0.toNumber(), 0, "owner must have some tokens");
    const balance0 = await token.balanceOf(validator.address);
    assert.strictEqual(balance0.toNumber(), 0, "initial balance must be 0");
    await token.transfer(validator.address, 20, {from: owner});
    const balance1 = await token.balanceOf(validator.address);
    assert.strictEqual(balance1.toNumber(), 20, "ERC20 transfer should succeed");
    await validator.reclaimToken(token.address);
    const balance2 = await token.balanceOf(validator.address);
    assert.strictEqual(balance2.toNumber(), balance0.toNumber(), "mismatch in token before and after");
    const amount1 = await token.balanceOf(owner);
    assert.strictEqual(amount1.toNumber(), amount0.toNumber(), "unable to recover");
  });

  it("should be able to reclaim ownership of contracts", async () => {
    const recipient = await AcceptingRecipient.new();
    const owner0 = await recipient.owner();
    assert.strictEqual(owner0, owner, "incorrect original owner");
    await recipient.transferOwnership(validator.address, {from: owner0});
    const owner1 = await recipient.owner();
    assert.strictEqual(owner1, validator.address, "standard controller should be owner");
    await validator.reclaimContract(recipient.address);
    const owner2 = await recipient.owner();
    assert.strictEqual(owner2, owner0, "must be original owner after reclaiming ownership");
  });

  it("should be able to transfer ownership", async () => {
    const owner0 = await validator.owner();
    assert.strictEqual(owner0, owner, "incorrect original owner");

    await validator.transferOwnership(accounts[8], {from: owner0});
    const owner1 = await validator.owner();
    assert.strictEqual(owner1, owner0, "must be original owner before claiming ownership");

    await validator.claimOwnership({from: accounts[8]});
    const owner2 = await validator.owner();
    assert.strictEqual(owner2, accounts[8], "must be new owner address after claiming ownership");
  });

})
