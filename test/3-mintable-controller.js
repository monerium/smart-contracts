var MintableController = artifacts.require("./MintableController.sol");
var EthUtil = require("ethereumjs-util");

const hash = `0xa1de988600a42c4b4ab089b619297c17d53cffae5d5120d82d8a92d0bb3b78f2`;
const wallets = {
  "trust wallet": {
    address: `0xB0A6Ed7Fa5C6C5cc507840924591C1494eF47D04`, 
    signature: `0xb5354ef622856f2acd9926752828d609b74471fa349891c70ec4512da5b7b8695418c39d82057dc09c480e8e65c5362327e882033e670e24b6a701983d93e18e1c`,
  },
  "ledger s nano": {
    address: `0x4A6bBDa876699420965147c26C3F3DF0bDc8eCab`,
    signature: `0xbad1a0d53be0e56724d877e053a199ca732c5e6e40d129c5a0980aa7d2c6582166af81969b23004ae81694e9518dcf39eb3af71d2847409376151f03465a0bf600`,
  },
  "meta mask": {
    address: `0xFB7ce0578B4dc16803A3CB04fA0b286fCFfFF76d`,
    signature: `0x1e1769b8ca9ca3d7d4b747f15336c185aac391c89cd9b9bfaf26f0a38631690e64ccd925382278c055c527a58ffab853a9734d889a6bae2b920544645f8ce4361c`,
  },
  "trezor": {
    address: `0xbc89Bea7B6156be4514f5D429e30240F4C2600e4`,
    signature: `0x884d210ebc1437a56e4507c47a5fadcf1076ef366d37d23937a515e8af63075605fbb6be98a9c9dd41bfc68b57795c79375ef10e34a8bf90701a2200ff5cc59d1b`,
  },
};

contract('MintableController', accounts => {

  if (web3.version.network <= 100) return;

  const owner = accounts[0];
  const system = accounts[9];
  let controller;

  beforeEach("setup mintable controller", async () => { 
    controller = await MintableController.deployed();
    await controller.addSystemAccount(system);
  });

  const key = Buffer.from("23f2ee33c522046e80b67e96ceb84a05b60b9434b0ee2e3ae4b1311b9f5dcc46", "hex");
  const address = `0x${EthUtil.privateToAddress(key).toString("hex")}`;

  it("should start with zero tokens", async () => {
    const supply = await controller.totalSupply();
    assert.equal(supply.valueOf(), 0, "initial supply is not 0");  
  });

  it("should fail to mint 666 new tokens from non-system account", async () => {
    try {
      await controller.mintTo_withCaller(accounts[0], accounts[0], 666, {from: accounts[0]});
    } catch { 
      return;
    }
    assert.fail("succeeded", "fail", "minting should fail from non-system account");
  });

  it("should fail to burn 777 new tokens from non-system account", async () => {
    await controller.addSystemAccount(accounts[8]); 
    await controller.mintTo_withCaller(accounts[8], accounts[8], 777, {from: accounts[8]});
    await controller.removeSystemAccount(accounts[8]);
    try {
      await controller.burn_withCaller(accounts[8], 777, {from: accounts[8]});
    } catch { 
      return;
    }
    assert.fail("succeeded", "fail", "burn should fail from non-system account");
  });

  it("should fail to burnFrom 888 new tokens from non-system account", async () => {
    await controller.addSystemAccount(accounts[8]); 
    await controller.mintTo_withCaller(accounts[8], accounts[7], 888, {from: accounts[8]});
    await controller.removeSystemAccount(accounts[8]);
    try {
      await controller.burnFrom_withCaller(accounts[8], accounts[7], 888, {from: accounts[8]});
    } catch { 
      return;
    }
    assert.fail("succeeded", "fail", "burnFrom should fail from non-system account");
  });

  it("should mint 48000 new tokens", async () => {
    await controller.mintTo_withCaller(system, system, 48000, {from: system});
    const balance = await controller.balanceOf(system);
    assert.equal(balance.valueOf(), 48000, "did not mint 48000 tokens");
  });

  it("should burn 1700 tokens from a system account (using a system account)", async () => {
    await controller.burn_withCaller(system, system, 1700, {from: system});
    const balance = await controller.balanceOf(system);
    assert.equal(balance.valueOf(), 46300, "remaining tokens should be 46300");
  });

  it("should fail burning 1800 tokens from a non-system account (using a system account)", async () => {
    await controller.mintTo_withCaller(system, accounts[4], 1800, {from: system});
    const initial = await controller.balanceOf(accounts[4]);
    assert.strictEqual(initial.toNumber(), 1800, "initial tokens incorrect");
    try {
      await controller.burn_withCaller(system, accounts[4], 1800, {from: system});
      assert.fail("burn should fail");
    } catch {
    }
    const balance = await controller.balanceOf(accounts[4]);
    assert.equal(balance.toNumber(), initial.toNumber(), "balance does not equal initial");
  });

  it("should burn 1100 tokens from a system account (using a different system account)", async () => {
    await controller.mintTo_withCaller(system, accounts[5], 1100, {from: system});
    const initial = await controller.balanceOf(accounts[5]);
    assert.strictEqual(initial.toNumber(), 1100, "initial tokens incorrect");
    await controller.addSystemAccount(accounts[5]);
    await controller.burn_withCaller(system, accounts[5], 1100, {from: system});
    const balance = await controller.balanceOf(accounts[5]);
    assert.equal(balance.toNumber(), initial.toNumber()-1100, "did not burn right amount of tokens");
  });

  it("should mint 82300 tokens to a non-system address", async () => {
    await controller.mintTo_withCaller(system, address, 82300, {from: system});
    const balance = await controller.balanceOf(address);
    assert.strictEqual(balance.toNumber(), 82300, "did not mint 82300 tokens");
  });

  var i = 5;
  for(var name in wallets) {
    const wallet = wallets[name];
    it(`should burn 82000 tokens from a non-system address [${name}]`, async () => {
      await controller.mintTo_withCaller(system, wallet.address, 82000, {from: system});
      const balance0 = await controller.balanceOf(wallet.address);

      const sig = wallet.signature.replace(/^0x/, '');
      const r = `0x${sig.slice(0, 64)}`;
      const s = `0x${sig.slice(64, 128)}`;
      var v = web3.toDecimal(`0x${sig.slice(128, 130)}`);

      if (v < 27) v += 27;
      assert(v == 27 || v == 28);

      await controller.burnFrom_withCaller(system, wallet.address, 82000, hash, v, r, s, {from: system});
      const balance1 = await controller.balanceOf(wallet.address);
      assert.strictEqual(balance1.toNumber()-balance0.toNumber(), -82000, "did not burn 82000 tokens");
    });
  }

  it("should fail adding system account from a non-owner address", async () => {
    try {
      await controller.addSystemAccount(accounts[6], {from: accounts[5]});
    } catch { 
      return;
    }
    assert.fail("succeeded", "fail", "adding system account should fail from non-owner account");
  });

  it("should fail removing system account from a non-owner address", async () => {
    await controller.addSystemAccount(accounts[6], {from: owner});
    const success = await controller.isSystemAccount(accounts[6]);
    assert.strictEqual(success, true, "unable to add system account");
    try {
      await controller.removeSystemAccount(accounts[6], {from: accounts[5]});
    } catch { 
      return;
    }
    assert.fail("succeeded", "fail", "removing system account should fail from non-owner account");
  });

  it("should succeed in adding system account from an owner address", async () => {
    await controller.addSystemAccount(accounts[7], {from: owner});
    const success = await controller.isSystemAccount(accounts[7]);
    assert.strictEqual(success, true, "unable to add system account");
  });

  it("should succeed in removing system account from an owner address", async () => {
    await controller.removeSystemAccount(accounts[7], {from: owner});
    const isSystem = await controller.isSystemAccount(accounts[7]);
    assert.strictEqual(isSystem, false, "unable to remove system account");
  });

});
