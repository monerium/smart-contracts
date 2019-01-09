var USD = artifacts.require("./USD.sol");
var SmartController = artifacts.require("./SmartController.sol");
var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");

contract("USD", accounts => {

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
    const controller = SmartController.at(await usd.getController());
    await controller.mint(74000, {from: system});
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

  it("should should fail transferring 78 tokens from a blacklisted account", async () => {
    (await BlacklistValidator.deployed()).ban(accounts[1]);
    try {
      await token.transfer(accounts[3], 78, {from: accounts[1]});
    } catch {
      return;
    }
    assert.fail("succeeded", "fail", "transfer was supposed to fail");
  });

});
