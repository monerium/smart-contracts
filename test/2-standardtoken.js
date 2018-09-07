var StandardController = artifacts.require("./StandardController.sol");
var AcceptingRecipient = artifacts.require("./AcceptingRecipient.sol");
var RejectingRecipient = artifacts.require("./RejectingRecipient.sol");
var SimpleToken = artifacts.require("./SimpleToken.sol");

contract('StandardController', accounts => {

  if (web3.version.network <= 100) return;

  const controller = StandardController.at(StandardController.address);

  it("should have a total supply of 50000 tokens", async () => {
    const supply = await controller.totalSupply();
    assert.equal(supply.valueOf(), 50000, "The total supply isn't 50000");
  });

  it("should put 50000 tokens in the first account", async () => {
    const balance = await controller.balanceOf(accounts[0]);
    assert.equal(balance.valueOf(), 50000, "50000 wasn't in the first account");
  });

  it("should transfer 25000 to the second account", async () => {
    await controller.transfer(accounts[1], 25000, {from: accounts[0]});
    const balance = await controller.balanceOf(accounts[1]);
    assert.equal(balance.valueOf(), 25000, "25000 wasn't in the second account");
  });

  it("should allow the third account to spend 12000 from the second account", async () => {
    await controller.approve(accounts[2], 12000, {from: accounts[1]});
    const allowance = await controller.allowance(accounts[1], accounts[2]);
    assert.equal(allowance.valueOf(), 12000, "the allowance wasn't 12000");
  });

  it("should transfer 9300 from the second account to the fourth using the third account", async () => {
    await controller.transferFrom(accounts[1], accounts[3], 9300, {from: accounts[2]});
    const balance = await controller.balanceOf(accounts[3]);
    assert.equal(balance.valueOf(), 9300, "The forth account does not have 9300");
  });

  it("should transfer 456 to an accepting contract", async () => {
    await controller.transferAndCall(AcceptingRecipient.address, 456, 0x10, {from: accounts[3]});
    const recipient = AcceptingRecipient.at(AcceptingRecipient.address)
    const from = await recipient.from();
    assert.equal(from, accounts[3], "from address not stored in recipient");
    const amount = await recipient.amount();
    assert.equal(amount, 456, "amount not stored in recipient");
    const data = await recipient.data();
    assert.equal(data, 0x10, "data not stored in recipient");
  });

  it("should not transfer 123 to a rejecting contract", async () => {
    try {
      await controller.transferAndCall(RejectingRecipient.address, 123, 0x20, {from: accounts[3]});
    } catch {
      return;
    }
    assert.fail("succeeded", "fail", "transfer and call was supposed to fail");
  });

  it("should be claimable", async () => {
    await controller.transferOwnership(accounts[1]);
    const owner0 = await controller.owner();
    assert.equal(owner0, accounts[0], "not original owner");
    await controller.claimOwnership({from: accounts[1]});
    const owner1 = await controller.owner();
    assert.equal(owner1, accounts[1], "ownership claim failed");
    await controller.transferOwnership(accounts[0], {from: accounts[1]});
    await controller.claimOwnership({from: accounts[0]});
    const owner = await controller.owner();
    assert.equal(owner, accounts[0], "should be owned by original owner");
  });

  it("should avoid blackholes [0x0]", async () => {
    try {
      await controller.transfer(0x0, 1);
    } catch {
      return;
    }
    assert.fail("succeeded", "fail", "transfer and call was supposed to fail");
  });

  it("should avoid blackholes [controller]", async () => {
    try {
      await controller.transfer(StandardController.address, 2);
    } catch {
      return;
    }
    assert.fail("succeeded", "fail", "transfer and call was supposed to fail");
  });

  it("should avoid blackholes [storage]", async () => {
    const storage = await controller.getStorage();
    try {
      await controller.transfer(storage, 3);
    } catch {
      return;
    }
    assert.fail("succeeded", "fail", "transfer and call was supposed to fail");
  });

  it("should avoid blackholes [frontend]", async () => {
    const frontend = await controller.getFrontend();
    try {
      await controller.transfer(frontend, 4);
    } catch {
      return;
    }
    assert.fail("succeeded", "fail", "transfer and call was supposed to fail");
  });

  it("should be pausable", async () => {
    await controller.pause({from: accounts[0]});
    try {
      await controller.transfer(accounts[2], 5, {from: accounts[1]});
    } catch {
      await controller.unpause({from: accounts[0]});
      await controller.transfer(accounts[2], 5, {from: accounts[1]});
      return;
    }
    assert.fail("succeeded", "fail", "transfer and call was supposed to fail");
  });

  it("should be able to reclaim ownership of contracts", async () => {
    const recipient = AcceptingRecipient.at(AcceptingRecipient.address)
    const owner0 = await recipient.owner();
    assert.strictEqual(owner0, accounts[0], "incorrect original owner");
    await recipient.transferOwnership(StandardController.address, {from: owner0});
    const owner1 = await recipient.owner();
    assert.strictEqual(owner1, StandardController.address, "standard controller should be owner");
    await controller.reclaimContract(AcceptingRecipient.address);
    const owner2 = await recipient.owner();
    assert.strictEqual(owner2, owner0, "must be original owner after reclaiming ownership");
  });

  it("should not be allowed to receive ether", async () => {
    try {
    await web3.eth.sendTransaction({to: StandardController.address, from: accounts[0], value: 10});
    } catch {
      return;
    }
    assert.fail("succeeded", "fail", "transfer and call was supposed to fail");
  });

  it("should not be allowed to receive tokens (ERC223, ERC677)", async () => {
    try {
      await controller.transferAndCall(StandardController.address, 223, 0x0);
    } catch {
      return;
    }
    assert.fail("succeeded", "fail", "transfer and call was supposed to fail");
  });

  it("should be able to recover tokens (ERC20)", async () => {
    const token = SimpleToken.at(SimpleToken.address);
    const amount0 = await token.balanceOf(accounts[0]);
    assert.notEqual(amount0.toNumber(), 0, "owner must have some tokens");
    const balance0 = await token.balanceOf(StandardController.address);
    assert.strictEqual(balance0.toNumber(), 0, "initial balance must be 0");
    await token.transfer(StandardController.address, 20, {from: accounts[0]});
    const balance1 = await token.balanceOf(StandardController.address);
    assert.strictEqual(balance1.toNumber(), 20, "ERC20 transfer should succeed");
    await controller.reclaimToken(token.address);
    const balance2 = await token.balanceOf(StandardController.address);
    assert.strictEqual(balance2.toNumber(), balance0.toNumber(), "mismatch in token before and after");
    const amount1 = await token.balanceOf(accounts[0]);
    assert.strictEqual(amount1.toNumber(), amount0.toNumber(), "unable to recover");
  });

  it("should be destructible", async () => {
    await controller.destroy();
    try {
      await controller.balanceOf(0x0);
    } catch {
      return;
    }
    assert.fail("succeeded", "fail", "contract should be destroyed");
  });

});
