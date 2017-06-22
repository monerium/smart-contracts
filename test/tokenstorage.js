var TokenStorage = artifacts.require("./TokenStorage.sol");

contract("TokenStorage", () => {
  it("should not have initial supply", () => {
    return TokenStorage.deployed().then((db) => {
      return db.totalSupply();
    }).then((supply) => {
      assert.equal(supply.valueOf(), 0, "total supply is not 0");
    });
  });
  it("should have a supply of 10000 after explicitly setting to 10000", (accounts) => {
    return TokenStorage.deployed().then((db) => {
      db.addBalance(accounts[0], 10000).then(() => {
        return db.totalSupply();
      }).then((supply) => {
        assert.equal(supply.valueOf(), 1000, "total supply is not 10000");
      });
    });
  });
});
