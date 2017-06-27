var MintableController = artifacts.require("./MintableController.sol");

contract('MintableController', (accounts) => {
  it("should start with zero tokens", () => {
    return MintableController.deployed().then(
      (token) => token.totalSupply()
    ).then((supply) => {
      assert.equal(supply.valueOf(), 0, "initial supply is not 0");  
    });
  });
  it("should mint 48000 new tokens", () => {
    var token;
    return MintableController.deployed().then((_token) => {
      token = _token;
      return token.mint(48000, {from: accounts[0]});
    }).then(
      () => token.balanceOf(accounts[0])
    ).then((balance) => {
      assert.equal(balance.valueOf(), 48000, "did not mint 48000 tokens");
    });
  });
  it("should burn 1700 tokens", () => {
    var token;
    return MintableController.deployed().then((_token) => {
      token = _token;
      return token.burn(1700, {from: accounts[0]});
    }).then(
      () => token.balanceOf(accounts[0])
    ).then((balance) => {
      assert.equal(balance.valueOf(), 46300, "remaining tokens should be 46300");
    });
  });
});
