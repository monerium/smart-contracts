var StandardController = artifacts.require("./StandardController.sol");
var TokenStorage = artifacts.require("./TokenStorage.sol");
var AcceptingRecipient = artifacts.require("./AcceptingRecipient.sol");
var RejectingRecipient = artifacts.require("./RejectingRecipient.sol");
var SimpleToken = artifacts.require("./SimpleToken.sol");
var TokenStorage = artifacts.require("./TokenStorage.sol");
var USD = artifacts.require("./USD.sol");

contract('StandardController', accounts => {

  if (web3.version.network <= 100) return;

  const owner = accounts[0];
  let controller;

  beforeEach("setup standard controller", async () => { 
    controller = await StandardController.deployed();
  });

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
    const recipient = await AcceptingRecipient.deployed();
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

  it("should be able to change ownership of its storage", async () => {
    const storage = TokenStorage.at(await controller.getStorage());
    const owner0 = await storage.owner();
    assert.strictEqual(owner0, controller.address, "incorrect original owner");
    await controller.transferStorageOwnership(accounts[0]);
    await storage.claimOwnership({from: accounts[0]})
    const owner1 = await storage.owner();
    assert.strictEqual(owner1, accounts[0], "unable to transfer/claim ownership");
    await storage.transferOwnership(controller.address);
    await controller.claimStorageOwnership();
    const owner2 = await storage.owner();
    assert.strictEqual(owner2, owner0, "controller should be the storage owner");
  });

  it("should fail to set a new storage from a non-owner account", async () => {
    const initial = await controller.getStorage();
    const storage = await TokenStorage.deployed();
    assert.notEqual(storage.address, initial, "initial storage should not be a newly instantiated storage");
    try {
      await controller.setStorage(storage.address, {from: accounts[7]});
    } catch {
    }
    const post = await controller.getStorage();
    assert.strictEqual(post, initial, "storage should not change");
  });

  it("should be able to set a new storage from an owner account", async () => {
    const initial = await controller.getStorage();
    const storage = await TokenStorage.deployed();
    assert.notEqual(storage.address, initial, "initial storage should not be a newly instantiated storage");
    await controller.setStorage(storage.address, {from: owner});
    const post = await controller.getStorage();
    assert.strictEqual(post, storage.address, "storage did not change");
  });

  it("should fail to set the frontend as a non-owner", async () => {
    const initial = await controller.getFrontend();
    const frontend = await USD.deployed();
    assert.notEqual(frontend.address, initial, "initial frontend should not be a newly instantiated frontend");
    try {
      await controller.setFrontend(frontend.address, {from: accounts[9]});
    } catch {
    }
    const post = await controller.getFrontend();
    assert.strictEqual(post, initial, "frontend should not change");
  });

  it("should be able to set the frontend as an owner", async () => {
    const initial = await controller.getFrontend();
    const frontend = await USD.deployed();
    assert.notEqual(frontend.address, initial, "initial frontend should not be a newly instantiated frontend");
    await controller.setFrontend(frontend.address, {from: owner});
    const post = await controller.getFrontend();
    assert.strictEqual(post, frontend.address, "frontend did not change");
  });

  it("should be destructible", async () => {
    const initial = await controller.owner();
    assert.notEqual(initial, "0x", "contract should be owned by someone");
    assert.strictEqual(initial, owner);
    await controller.destroy();
    let owner0;
    try {
      owner0 = await controller.owner()
    } catch {
      return;
    }
    assert.strictEqual(owner0, "0x", "after destroying contract it should be ownerless");
  });

});
