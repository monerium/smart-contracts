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
    const sig = signature.replace(/^0x/, '');
    const r = `0x${sig.slice(0, 64)}`;
    const s = `0x${sig.slice(64, 128)}`;
    var v = web3.toDecimal(`0x${sig.slice(128, 130)}`);

    if (v < 27) v += 27;
    assert(v == 27 || v == 28);

    await controller.mintTo(address, 82300, hash, v, r, s);
    const balance = await controller.balanceOf(address);
    assert.strictEqual(balance.toNumber(), 82300, "did not mint 82300 tokens");
  });

  it("should burn 82000 tokens to a non-owner address", async () => {
    const balance0 = await controller.balanceOf(address);

    const sig = signature.replace(/^0x/, '');
    const r = `0x${sig.slice(0, 64)}`;
    const s = `0x${sig.slice(64, 128)}`;
    var v = web3.toDecimal(`0x${sig.slice(128, 130)}`);

    if (v < 27) v += 27;
    assert(v == 27 || v == 28);

    await controller.burnFrom(address, 82000, hash, v, r, s);
    const balance1 = await controller.balanceOf(address);
    assert.strictEqual(balance1.toNumber()-balance0.toNumber(), -82000, "did not burn 82000 tokens");
  });

});
