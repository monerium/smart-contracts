var SmartController = artifacts.require("./SmartController.sol");
var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");

contract('SmartController', (accounts) => {
  it("should start with zero tokens", () => {
    return SmartController.deployed().then(
      (token) => token.totalSupply()
    ).then((supply) => {
      assert.equal(supply.valueOf(), 0, "initial supply is not 0");  
    });
  });
  it("should mint 88000 new tokens", () => {
    var token;
    return SmartController.deployed().then((_token) => {
      token = _token;
      return token.mint(88000, {from: accounts[0]});
    }).then(
      () => token.mint(33000, {from: accounts[2]})
    ).then(
      () => token.balanceOf(accounts[0])
    ).then((balance) => {
      assert.equal(balance.valueOf(), 88000, "did not mint 88000 tokens");
    });
  });
  it("should transfer 3400 tokens to second account", () => {
    var token;
    return SmartController.deployed().then((_token) => {
      token = _token;
      token.transfer(accounts[1], 3400, {from: accounts[0]});
    }).then(
      () => token.balanceOf(accounts[1])
    ).then((balance) => {
      assert.equal(balance.valueOf(), 3400, "did not transfer 3400 tokens"); 
    });
  });
  it("should should fail transferring 1840 tokens from a blacklisted account", () => {
    var token;
    return SmartController.deployed().then((_token) => {
      token = _token;
      return token.getValidator();
    }).then(
      (validator) => BlacklistValidator.at(validator).ban(accounts[2])
    ).then(
      () => token.transfer(accounts[3], 1840, {from: accounts[2]})
    ).then(() => {
      assert.fail("succeeded", "fail", "transfer was supposed to fail");
    }).catch((e) => {
      assert.notEqual(e.name, "AssertionError");
    });
  });
});

