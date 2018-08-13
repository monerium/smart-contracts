var TokenStorage = artifacts.require("./TokenStorage.sol");

const storage = TokenStorage.at(TokenStorage.address);

contract("TokenStorage", accounts => {

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

});
