var TokenStorage = artifacts.require("./TokenStorage.sol");
var AcceptingRecipient = artifacts.require("./AcceptingRecipient.sol");
var SimpleToken = artifacts.require("./SimpleToken.sol");
var StandardController = artifacts.require("./StandardController.sol");

contract("TokenStorage", accounts => {

  if (web3.version.network <= 100) return;

  const storage = TokenStorage.at(TokenStorage.address);
  const controller = StandardController.at(StandardController.address);

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
    try {
      await storage.addBalance(accounts[3], 1000000, {from: accounts[4]});
    } catch { 
      return;
    }
    assert.fail("succeeded", "fail", "minting was supposed to fail");
  });

  it("should be able to reclaim ownership of contracts", async () => {
    const recipient = AcceptingRecipient.at(AcceptingRecipient.address)
    const owner0 = await recipient.owner();
    assert.strictEqual(owner0, accounts[0], "incorrect original owner");
    await recipient.transferOwnership(TokenStorage.address, {from: owner0});
    const owner1 = await recipient.owner();
    assert.strictEqual(owner1, TokenStorage.address, "standard controller should be owner");
    await storage.reclaimContract(AcceptingRecipient.address);
    const owner2 = await recipient.owner();
    assert.strictEqual(owner2, owner0, "must be original owner after reclaiming ownership");
  });

  it("should not be allowed to receive ether", async () => {
    try {
    await web3.eth.sendTransaction({to: TokenStorage.address, from: accounts[0], value: 10});
    } catch {
      return;
    }
    assert.fail("succeeded", "fail", "transfer and call was supposed to fail");
  });

  it("should not be allowed to receive tokens (ERC223, ERC677)", async () => {
    try {
      await controller.transferAndCall(TokenStorage.address, 223, 0x0);
    } catch {
      return;
    }
    assert.fail("succeeded", "fail", "transfer and call was supposed to fail");
  });

  it("should be able to recover tokens (ERC20)", async () => {
    const token = SimpleToken.at(SimpleToken.address);
    const amount0 = await token.balanceOf(accounts[0]);
    assert.notEqual(amount0.toNumber(), 0, "owner must have some tokens");
    const balance0 = await token.balanceOf(TokenStorage.address);
    assert.strictEqual(balance0.toNumber(), 0, "initial balance must be 0");
    await token.transfer(TokenStorage.address, 20, {from: accounts[0]});
    const balance1 = await token.balanceOf(TokenStorage.address);
    assert.strictEqual(balance1.toNumber(), 20, "ERC20 transfer should succeed");
    await storage.reclaimToken(token.address);
    const balance2 = await token.balanceOf(TokenStorage.address);
    assert.strictEqual(balance2.toNumber(), balance0.toNumber(), "mismatch in token before and after");
    const amount1 = await token.balanceOf(accounts[0]);
    assert.strictEqual(amount1.toNumber(), amount0.toNumber(), "unable to recover");
  });

});
