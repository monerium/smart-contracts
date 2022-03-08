var truffleAssert = require('truffle-assertions');
var ISK = artifacts.require("./ISK.sol");
var AcceptingRecipient = artifacts.require("./AcceptingRecipient.sol");
var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");
var SimpleToken = artifacts.require("./SimpleToken.sol");
var SmartController = artifacts.require("./SmartController.sol");

var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var SmartTokenLib = artifacts.require("./SmartTokenLib.sol");
var TokenStorageLib = artifacts.require("./TokenStorageLib.sol");
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var ERC677Lib = artifacts.require("./ERC677Lib.sol");

const AddressZero = "0x0000000000000000000000000000000000000000";

contract("ISK", accounts => {

  if (web3.version.network <= 100) return;

  let isk;
  let validator;

  before("setup isk", async () => {
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

    // Deploy
    isk = await ISK.new();
    validator = await BlacklistValidator.new();
    const controller = await SmartController.new(AddressZero, validator.address, web3.utils.asciiToHex("ISK"), isk.address);
    await isk.setController(controller.address);
  });

  it("should start with zero tokens", async () => {
    const supply = await isk.totalSupply();
    assert.equal(supply.valueOf(), 0, "initial supply is not 0");
  });

  it("should be able to reclaim ownership of contracts", async () => {
    const recipient = await AcceptingRecipient.new();
    const owner0 = await recipient.owner();
    assert.strictEqual(owner0, accounts[0], "incorrect original owner");
    await recipient.transferOwnership(isk.address, {from: owner0});
    const owner1 = await recipient.owner();
    assert.strictEqual(owner1, isk.address, "standard controller should be owner");
    await isk.reclaimContract(recipient.address);
    const owner2 = await recipient.owner();
    assert.strictEqual(owner2, owner0, "must be original owner after reclaiming ownership");
  });

  it("should be able to recover tokens (ERC20)", async () => {
    const token = await SimpleToken.new();
    const amount0 = await token.balanceOf(accounts[0]);
    assert.notEqual(amount0.toNumber(), 0, "owner must have some tokens");
    const balance0 = await token.balanceOf(isk.address);
    assert.strictEqual(balance0.toNumber(), 0, "initial balance must be 0");
    await token.transfer(isk.address, 20, {from: accounts[0]});
    const balance1 = await token.balanceOf(isk.address);
    assert.strictEqual(balance1.toNumber(), 20, "ERC20 transfer should succeed");
    await isk.reclaimToken(token.address);
    const balance2 = await token.balanceOf(isk.address);
    assert.strictEqual(balance2.toNumber(), balance0.toNumber(), "mismatch in token before and after");
    const amount1 = await token.balanceOf(accounts[0]);
    assert.strictEqual(amount1.toNumber(), amount0.toNumber(), "unable to recover");
  });

});
