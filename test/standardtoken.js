var StandardController = artifacts.require("./StandardController.sol");

contract('StandardController', (accounts) => {
  it("should have a total supply of 50000 tokens", () => {
    return StandardController.deployed().then((token) => {
      return token.totalSupply();
    }).then((supply) => {
      assert.equal(supply.valueOf(), 50000, "The total supply isn't 50000");
    });
  });
  it("should put 50000 tokens in the first account", () => {
    return StandardController.deployed().then((token) => {
      return token.balanceOf(accounts[0]);
    }).then((balance) => {
      assert.equal(balance.valueOf(), 50000, "50000 wasn't in the first account");
    });
  });
  it("should transfer 25000 to the second account", () => {
    var token;
    return StandardController.deployed().then((_token) => {
      token = _token;
      return token.transfer(accounts[1], 25000, {from: accounts[0]});
      // return
    }).then(
      () => token.balanceOf(accounts[1])
    ).then((balance) => {
      assert.equal(balance.valueOf(), 25000, "25000 wasn't in the second account");
    });
  });
  it("should allow the third account to spend 12000 from the second account", () => {
    var token;
    return StandardController.deployed().then((_token) => {
      token = _token;
      return token.approve(accounts[2], 12000, {from: accounts[1]});
    }).then(
      () => token.allowance(accounts[1], accounts[2])
    ).then((allowance) => {
      assert.equal(allowance.valueOf(), 12000, "the allowance wasn't 12000");
    });
  });
});
