var truffleAssert = require('truffle-assertions');
var ConstantValidator = artifacts.require("./ConstantValidator.sol");
var AcceptingRecipient = artifacts.require("./AcceptingRecipient.sol");
var SimpleToken = artifacts.require("./SimpleToken.sol");
var StandardController = artifacts.require("./StandardController.sol");

const AddressZero = "0x0000000000000000000000000000000000000000";

contract("ConstantValidator", accounts => {

  if (web3.version.network <= 100) return;

  const owner = accounts[0];
  let validator;

  before("setup constant validator", async () => {
    validator = await ConstantValidator.new(true);
  });

  it("should validate (from 0x0, to 0x0, amount 0)", async () => {
    // unable to check return value since the method is non-pure because it emits an event.
    await validator.validate(AddressZero, AddressZero, 0);
  });

  it("should be able to reclaim ownership of contracts", async () => {
    const recipient = await AcceptingRecipient.new();
    const owner0 = await recipient.owner();
    assert.strictEqual(owner0, accounts[0], "incorrect original owner");
    await recipient.transferOwnership(validator.address, {from: owner0});
    const owner1 = await recipient.owner();
    assert.strictEqual(owner1, validator.address, "standard controller should be owner");
    await validator.reclaimContract(recipient.address);
    const owner2 = await recipient.owner();
    assert.strictEqual(owner2, owner0, "must be original owner after reclaiming ownership");
  });

  it("should be able to recover tokens (ERC20)", async () => {
    const token = await SimpleToken.new();
    const amount0 = await token.balanceOf(accounts[0]);
    assert.notEqual(amount0.toNumber(), 0, "owner must have some tokens");
    const balance0 = await token.balanceOf(validator.address);
    assert.strictEqual(balance0.toNumber(), 0, "initial balance must be 0");
    await token.transfer(validator.address, 20, {from: accounts[0]});
    const balance1 = await token.balanceOf(validator.address);
    assert.strictEqual(balance1.toNumber(), 20, "ERC20 transfer should succeed");
    await validator.reclaimToken(token.address);
    const balance2 = await token.balanceOf(validator.address);
    assert.strictEqual(balance2.toNumber(), balance0.toNumber(), "mismatch in token before and after");
    const amount1 = await token.balanceOf(accounts[0]);
    assert.strictEqual(amount1.toNumber(), amount0.toNumber(), "unable to recover");
  });

})
