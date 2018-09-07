var MintableController = artifacts.require("./MintableController.sol");
var EthUtil = require("ethereumjs-util");

contract('MintableController', accounts => {

  if (web3.version.network <= 100) return;

  const controller = MintableController.at(MintableController.address);
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

  it("should not burn 82000 tokens from a non-owner address [fails blockheight]", async () => {
    const height = await web3.eth.blockNumber;
    const hash = EthUtil.hashPersonalMessage(Buffer.from(height.toString()));
    const sig = EthUtil.ecsign(hash, key);
    const r = `0x${sig.r.toString("hex")}`;
    const s = `0x${sig.s.toString("hex")}`;
    const v = sig.v;

    if (v < 27) v += 27;
    assert(v == 27 || v == 28);

    try {
      await controller.burnFrom(address, 82000, height, v, r, s);
    } catch (e) {
      return;
    }
    assert.fail("succeeded", "fail", "burn from address was supposed to fail");
  });

  it("should burn 82000 tokens from a non-owner address", async () => {
    const height = await web3.eth.blockNumber+1;
    const hash = EthUtil.hashPersonalMessage(Buffer.from(height.toString()));
    const sig = EthUtil.ecsign(hash, key);
    const r = `0x${sig.r.toString("hex")}`;
    const s = `0x${sig.s.toString("hex")}`;
    const v = sig.v;

    if (v < 27) v += 27;
    assert(v == 27 || v == 28);

    const balance0 = await controller.balanceOf(address);
    await controller.burnFrom(address, 82000, height, v, r, s);
    const balance1 = await controller.balanceOf(address);
    assert.strictEqual(balance1.toNumber()-balance0.toNumber(), -82000, "did not burn 82000 tokens");
  });

});
