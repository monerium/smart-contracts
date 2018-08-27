var MintableController = artifacts.require("./MintableController.sol");

const controller = MintableController.at(MintableController.address);
const address = `0xFB7ce0578B4dc16803A3CB04fA0b286fCFfFF76d`;
const hash = `0xa1de988600a42c4b4ab089b619297c17d53cffae5d5120d82d8a92d0bb3b78f2`;
const signature = `0x1e1769b8ca9ca3d7d4b747f15336c185aac391c89cd9b9bfaf26f0a38631690e64ccd925382278c055c527a58ffab853a9734d889a6bae2b920544645f8ce4361c`;

contract('MintableController', accounts => {

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

    // const signature1 = '0xe1965b11d51ae7f1b7c310bdac5e337ef79d71fa145c15318352e41d6affe70f659815dfd79d85f5290955a1aea9fabd6133d4c31bede2cb4b25735f60a55bb81b';
    const signature1 = '0xc88fee880e28de7db09d22de099063bed815fdf7fafc674a148ada7c1c53719a2360f794f0ba81767f92d93eaceedb9875966019a630dbd8735d35401ba897cf1c';
    const sig = signature1.replace(/^0x/, '');
    const r = `0x${sig.slice(0, 64)}`;
    const s = `0x${sig.slice(64, 128)}`;
    var v = web3.toDecimal(`0x${sig.slice(128, 130)}`);

    if (v < 27) v += 27;
    assert(v == 27 || v == 28);

    await controller.burnFrom(address, 82000, 100, v, r, s);
    const balance1 = await controller.balanceOf(address);
    assert.strictEqual(balance1.toNumber()-balance0.toNumber(), -82000, "did not burn 82000 tokens");
  });

});
