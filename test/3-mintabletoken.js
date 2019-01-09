var MintableController = artifacts.require("./MintableController.sol");
var EthUtil = require("ethereumjs-util");

contract('MintableController', accounts => {

  if (web3.version.network <= 100) return;

  let controller;

  beforeEach("setup mintable controller", async () => { 
    controller = await MintableController.deployed();
  });

  const key = Buffer.from("23f2ee33c522046e80b67e96ceb84a05b60b9434b0ee2e3ae4b1311b9f5dcc46", "hex");
  const address = `0x${EthUtil.privateToAddress(key).toString("hex")}`;

  it("should start with zero tokens", async () => {
    const supply = await controller.totalSupply();
    assert.equal(supply.valueOf(), 0, "initial supply is not 0");  
  });

  it("should mint 48000 new tokens", async () => {
    await controller.mint(48000, {from: accounts[0]});
    const balance = await controller.balanceOf(accounts[0]);
    assert.equal(balance.valueOf(), 48000, "did not mint 48000 tokens");
  });

  it("should burn 1700 tokens", async () => {
    await controller.burn(1700, {from: accounts[0]});
    const balance = await controller.balanceOf(accounts[0]);
    assert.equal(balance.valueOf(), 46300, "remaining tokens should be 46300");
  });

  it("should mint 82300 tokens to a non-owner address", async () => {
    await controller.mintTo(address, 82300);
    const balance = await controller.balanceOf(address);
    assert.strictEqual(balance.toNumber(), 82300, "did not mint 82300 tokens");
  });

  it("should burn 82000 tokens from a non-owner address", async () => {
    const balance0 = await controller.balanceOf(address);
    await controller.burnFrom(address, 82000);
    const balance1 = await controller.balanceOf(address);
    assert.strictEqual(balance1.toNumber()-balance0.toNumber(), -82000, "did not burn 82000 tokens");
  });

});
