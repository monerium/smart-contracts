var USD = artifacts.require("./USD.sol");
var SmartController = artifacts.require("./SmartController.sol");
var StandardController = artifacts.require("./StandardController.sol");
var ConstantSmartController = artifacts.require("./ConstantSmartController.sol");
var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");
var AcceptingRecipient = artifacts.require("./AcceptingRecipient");
var RejectingRecipient = artifacts.require("./RejectingRecipient");
var SimpleToken = artifacts.require("./SimpleToken.sol");

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

contract("USD", accounts => {

  const owner = accounts[0];
  const system = accounts[9];
  let usd;

  beforeEach("setup usd", async () => { 
    usd = await USD.deployed();
    const controller = await SmartController.at(await usd.getController());
    await controller.addSystemAccount(system);
  });

  it("should start with zero tokens", async () => {
    const supply = await usd.totalSupply()
    assert.equal(supply.valueOf(), 0, "initial supply is not 0");  
  });

  it("should mint 74000 new tokens", async () => {
    await usd.mintTo(system, 74000, {from: system});
    const balance = await usd.balanceOf(system);
    assert.equal(balance.valueOf(), 74000, "did not mint 74000 tokens");
  });

  it("should transfer 7200 tokens to second account", async () => {
    await usd.transfer(accounts[1], 7200, {from: system});
    const balance = await usd.balanceOf(accounts[1]);
    assert.equal(balance.valueOf(), 7200, "did not transfer 7200 tokens"); 
  });

  it("should allow the third account to spend 9600 from the first account", async () => {
    await usd.transfer(accounts[0], 9600, {from: system});
    await usd.approve(accounts[2], 9600, {from: accounts[0]});
    const allowance = await usd.allowance(accounts[0], accounts[2]);
    assert.equal(allowance.valueOf(), 9600, "the allowance wasn't 9600");
  });

  it("should transfer 9300 from the first account to the fourth using the third account", async () => {
    await usd.transferFrom(accounts[0], accounts[3], 9300, {from: accounts[2]});
    const balance = await usd.balanceOf(accounts[3]);
    assert.equal(balance.valueOf(), 9300, "The forth account does not have 9300");
  });

  it("should fail transferring 78 tokens from a blacklisted account", async () => {
    (await BlacklistValidator.deployed()).ban(accounts[1]);
    try {
      await token.transfer(accounts[3], 78, {from: accounts[1]});
    } catch {
      return;
    }
    assert.fail("succeeded", "fail", "transfer was supposed to fail");
  });

  it("should succeed transferring to and calling a contract which implements token fallback method by accepting", async () => {
    const recipient = await AcceptingRecipient.deployed();
    await usd.transferAndCall(recipient.address, 3, "");
    const balance = await usd.balanceOf(recipient.address);
    assert.strictEqual(balance.toNumber(), 3, "balance mismatch for recipient");
  });

  it("should fail transferring to and calling a contract which implements token fallback method by rejecting", async () => {
    const recipient = await RejectingRecipient.deployed();
    try {
      await usd.transferAndCall(recipient.address, 3, "");
    } catch {
    }
    const balance = await usd.balanceOf(recipient.address);
    assert.strictEqual(balance.toNumber(), 0, "balance mismatch for recipient");
  });

  it("should fail transferring to and calling a contract which does not implements token fallback method", async () => {
    const recipient = await SimpleToken.deployed();
    try {
      await usd.transferAndCall(recipient.address, 3, "");
    } catch {
    }
    const balance = await usd.balanceOf(recipient.address);
    assert.strictEqual(balance.toNumber(), 0, "balance mismatch for recipient");
  });

  it("should succeed transferring to and calling a non-contract", async () => {
    const account = accounts[7];
    await usd.transferAndCall(account, 3, "");
    const balance = await usd.balanceOf(account);
    assert.strictEqual(balance.toNumber(), 3, "balance mismatch for account");
  });

  var i = 5;
  for(var name in wallets) {
    const wallet = wallets[name];
    it(`should burn 18 tokens from a non-system address [${name}]`, async () => {
      await usd.mintTo(wallet.address, 18, {from: system});
      const balance0 = await usd.balanceOf(wallet.address);

      const sig = wallet.signature.replace(/^0x/, '');
      const r = `0x${sig.slice(0, 64)}`;
      const s = `0x${sig.slice(64, 128)}`;
      var v = web3.toDecimal(`0x${sig.slice(128, 130)}`);

      if (v < 27) v += 27;
      assert(v == 27 || v == 28);

      await usd.burnFrom(wallet.address, 18, hash, v, r, s, {from: system});
      const balance1 = await usd.balanceOf(wallet.address);
      assert.strictEqual(balance1.toNumber()-balance0.toNumber(), -18, "did not burn 18 tokens");
    });
  }

  var i = 5;
  for(var name in wallets) {
    const account = accounts[i++];
    const wallet = wallets[name];
    it(`should be able to recover the balance of a known address to a new address [${name}]`, async () => {
      const balance0 = await usd.balanceOf(account);
      await usd.transfer(wallet.address, 13, {from: system});
      const sig = wallet.signature.replace(/^0x/, '');
      const r = `0x${sig.slice(0, 64)}`;
      const s = `0x${sig.slice(64, 128)}`;
      var v = web3.toDecimal(`0x${sig.slice(128, 130)}`);

      if (v < 27) v += 27;
      assert(v == 27 || v == 28);

      try {
        await usd.recover(wallet.address, account, hash, v, r, s, {from: system});
      } catch {
        assert.fail(`unable to recover ${name}`);
      }

      const balanceFrom = await usd.balanceOf(wallet.address);
      assert.equal(balanceFrom.valueOf(), 0, "did not recover 13 tokens");
      const balanceTo = await usd.balanceOf(account);
      assert.equal(balanceTo.toNumber()-balance0.toNumber(), 13, "did not recover 13 tokens");
    })
  }

  it("should burn 10 tokens from a system account (using a system account)", async () => {
    const balance0 = await usd.balanceOf(system);
    await usd.burn(system, 10, {from: system});
    const balance = await usd.balanceOf(system);
    assert.equal(balance.toNumber()-balance0.toNumber(), -10, "should have burned to tokens");
  });

  it("should return the decimal points for units in the contract", async () => {
    const decimals = await usd.decimals();
    assert.strictEqual(decimals.toNumber(), 18, "decimals do not match");
  });

  it("should fail to set the controller to 0x0", async () => {
    const initial = await usd.getController();
    try {
      await usd.setController(0x0);
    } catch {
    }
    const post = await usd.getController();
    assert.strictEqual(post, initial, "controller should not change");
  });

  it("should fail to set the controller to a non null address from a non-owner", async () => {
    const initial = await usd.getController();
    try {
      await usd.setController(0x0, {from: accounts[5]});
    } catch {
    }
    const post = await usd.getController();
    assert.strictEqual(post, initial, "controller should not change");
  });

  it("should fail to set the controller to a controller with different ticker", async () => {
    const initial = await usd.getController();
    const standard = await StandardController.deployed();
    assert.notEqual(standard.address, initial, "invalid initial controller");
    try {
      await usd.setController(standard.address, {from: owner});
    } catch {
    }
    const post = await usd.getController();
    assert.strictEqual(post, initial, "controller should not change");
  });

  it("should fail setting the controller to a non null address not pointing back", async () => {
    const initial = await usd.getController();
    const standard = await ConstantSmartController.deployed();
    try {
    await usd.setController(standard.address, {from: owner});
    } catch {
    }
    const post = await usd.getController();
    assert.strictEqual(post, initial, "incorrect post state");
  });

  it("should succeed setting the controller to a non null address pointing back", async () => {
    const standard = await ConstantSmartController.deployed();
    await standard.setFrontend(usd.address, {from: owner});
    await usd.setController(standard.address, {from: owner});
    const post = await usd.getController();
    assert.strictEqual(post, standard.address, "incorrect post state");
  });

  it("should be claimable", async () => {
    await usd.transferOwnership(accounts[1]);
    const owner0 = await usd.owner();
    assert.equal(owner0, accounts[0], "not original owner");
    await usd.claimOwnership({from: accounts[1]});
    const owner1 = await usd.owner();
    assert.equal(owner1, accounts[1], "ownership claim failed");
    await usd.transferOwnership(accounts[0], {from: accounts[1]});
    await usd.claimOwnership({from: accounts[0]});
    const owner = await usd.owner();
    assert.equal(owner, accounts[0], "should be owned by original owner");
  });

  it("should be able to reclaim ownership of contracts", async () => {
    const recipient = await AcceptingRecipient.deployed();
    const owner0 = await recipient.owner();
    assert.strictEqual(owner0, accounts[0], "incorrect original owner");
    await recipient.transferOwnership(USD.address, {from: owner0});
    const owner1 = await recipient.owner();
    assert.strictEqual(owner1, USD.address, "standard usd should be owner");
    await usd.reclaimContract(AcceptingRecipient.address);
    const owner2 = await recipient.owner();
    assert.strictEqual(owner2, owner0, "must be original owner after reclaiming ownership");
  });

  it("should be able to recover tokens (ERC20)", async () => {
    const token = await SimpleToken.deployed();
    const amount0 = await token.balanceOf(accounts[0]);
    assert.notEqual(amount0.toNumber(), 0, "owner must have some tokens");
    const balance0 = await token.balanceOf(USD.address);
    assert.strictEqual(balance0.toNumber(), 0, "initial balance must be 0");
    await token.transfer(USD.address, 20, {from: accounts[0]});
    const balance1 = await token.balanceOf(USD.address);
    assert.strictEqual(balance1.toNumber(), 20, "ERC20 transfer should succeed");
    await usd.reclaimToken(token.address);
    const balance2 = await token.balanceOf(USD.address);
    assert.strictEqual(balance2.toNumber(), balance0.toNumber(), "mismatch in token before and after");
    const amount1 = await token.balanceOf(accounts[0]);
    assert.strictEqual(amount1.toNumber(), amount0.toNumber(), "unable to recover");
  });

});
