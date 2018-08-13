var StandardController = artifacts.require("./StandardController.sol");

const controller = StandardController.at(StandardController.address);

contract('StandardController', accounts => {

  it("should have a total supply of 50000 tokens", async() => {
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

});
