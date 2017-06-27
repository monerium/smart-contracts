var USD = artifacts.require("./USD.sol");
var SmartController = artifacts.require("./SmartController.sol");

contract("USD", (accounts) => {
  it("should start with zero tokens", () => {
    return USD.deployed().then(
      (token) => token.totalSupply()
    ).then((supply) => {
      assert.equal(supply.valueOf(), 0, "initial supply is not 0");  
    });
  });
  it("should mint 74000 new tokens", () => {
    var token;
    return USD.deployed().then((_token) => {
      token = _token;
      return token.getController();
    }).then(
      (controller) => SmartController.at(controller).mint(74000, {from: accounts[0]})
    ).then(
      () => token.balanceOf(accounts[0])
    ).then((balance) => {
      assert.equal(balance.valueOf(), 74000, "did not mint 74000 tokens");
    });
  });
  it("should transfer 7200 tokens to second account", () => {
    var token;
    return USD.deployed().then((_token) => {
      token = _token;
      token.transfer(accounts[1], 7200, {from: accounts[0]});
    }).then(
      () => token.balanceOf(accounts[1])
    ).then((balance) => {
      assert.equal(balance.valueOf(), 7200, "did not transfer 7200 tokens"); 
    });
  });
  it("should allow the third account to spend 9600 from the first account", () => {
    var token;
    return USD.deployed().then((_token) => {
      token = _token;
      return token.approve(accounts[2], 9600, {from: accounts[0]});
    }).then(
      () => token.allowance(accounts[0], accounts[2])
    ).then((allowance) => {
      assert.equal(allowance.valueOf(), 9600, "the allowance wasn't 9600");
    });
  });
  it("should transfer 9300 from the first account to the fourth using the third account", () => {
    var token;
    return USD.deployed().then((_token) => {
      token = _token;
      return token.transferFrom(accounts[0], accounts[3], 9300, {from: accounts[2]});
    }).then(
      () => token.balanceOf(accounts[3])
    ).then((balance) => {
      assert.equal(balance.valueOf(), 9300, "The forth account does not have 9300");
    });
  });
});
