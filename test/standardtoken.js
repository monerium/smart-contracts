var StandardController = artifacts.require("./StandardController.sol");

contract('StandardController', (accounts) => {
  it("should have a total supply of 10000 tokens", () => {
    return StandardController.deployed().then((instance) => {
      return instance.totalSupply();
    }).then((supply) => {
      assert.equal(supply.valueOf(), 10000, "The total supply isn't 10000");
    });
  });
  it("should put 10000 tokens in the first account", () => {
    return StandardController.deployed().then((instance) => {
      return instance.balanceOf.call(accounts[0]);
    }).then((balance) => {
      assert.equal(balance.valueOf(), 1000, "10000 wasn't in the first account");
    });
  });
});
