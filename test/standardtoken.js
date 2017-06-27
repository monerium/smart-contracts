var StandardController = artifacts.require("./StandardController.sol");

contract('StandardController', (accounts) => {
  it("should have a total supply of 50000 tokens", () => {
    return StandardController.deployed().then((instance) => {
      return instance.totalSupply();
    }).then((supply) => {
      assert.equal(supply.valueOf(), 50000, "The total supply isn't 50000");
    });
  });
  it("should put 50000 tokens in the first account", () => {
    return StandardController.deployed().then((instance) => {
      return instance.balanceOf(accounts[0]);
    }).then((balance) => {
      assert.equal(balance.valueOf(), 50000, "50000 wasn't in the first account");
    });
  });
});
