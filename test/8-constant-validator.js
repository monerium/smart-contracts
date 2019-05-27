const ConstantValidator = artifacts.require("./ConstantValidator.sol");
const AcceptingRecipient = artifacts.require("./AcceptingRecipient.sol");
var SimpleToken = artifacts.require("./SimpleToken.sol");
var StandardController = artifacts.require("./StandardController.sol");

contract("ConstantValidator", accounts => {

  if (web3.version.network <= 100) return;

  const owner = accounts[0];
  let validator;

  beforeEach("setup constant validator", async () => { 
    validator = await ConstantValidator.deployed();
  });

  it("should validate (from 0x0, to 0x0, amount 0)", async () => {
    // unable to check return value since the method is non-pure because it emits an event.
    await validator.validate(0x0, 0x0, 0); 
  });

  it("should be able to reclaim ownership of contracts", async () => {
    const recipient = await AcceptingRecipient.deployed();
    const owner0 = await recipient.owner();
    assert.strictEqual(owner0, accounts[0], "incorrect original owner");
    await recipient.transferOwnership(ConstantValidator.address, {from: owner0});
    const owner1 = await recipient.owner();
    assert.strictEqual(owner1, ConstantValidator.address, "standard controller should be owner");
    await validator.reclaimContract(AcceptingRecipient.address);
    const owner2 = await recipient.owner();
    assert.strictEqual(owner2, owner0, "must be original owner after reclaiming ownership");
  });

  it("should not be allowed to receive ether", async () => {
    try {
    await web3.eth.sendTransaction({to: ConstantValidator.address, from: accounts[0], value: 10});
    } catch {
      return;
    }
    assert.fail("succeeded", "fail", "transfer and call was supposed to fail");
  });

  it("should not be allowed to receive tokens (ERC223, ERC677)", async () => {
    const controller = await StandardController.deployed();
    try {
      await controller.transferAndCall(ConstantValidator.address, 223, 0x0);
    } catch {
      return;
    }
    assert.fail("succeeded", "fail", "transfer and call was supposed to fail");
  });

  it("should be able to recover tokens (ERC20)", async () => {
    const token = await SimpleToken.deployed();
    const amount0 = await token.balanceOf(accounts[0]);
    assert.notEqual(amount0.toNumber(), 0, "owner must have some tokens");
    const balance0 = await token.balanceOf(ConstantValidator.address);
    assert.strictEqual(balance0.toNumber(), 0, "initial balance must be 0");
    await token.transfer(ConstantValidator.address, 20, {from: accounts[0]});
    const balance1 = await token.balanceOf(ConstantValidator.address);
    assert.strictEqual(balance1.toNumber(), 20, "ERC20 transfer should succeed");
    await validator.reclaimToken(token.address);
    const balance2 = await token.balanceOf(ConstantValidator.address);
    assert.strictEqual(balance2.toNumber(), balance0.toNumber(), "mismatch in token before and after");
    const amount1 = await token.balanceOf(accounts[0]);
    assert.strictEqual(amount1.toNumber(), amount0.toNumber(), "unable to recover");
  });

})
