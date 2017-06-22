var TokenStorage = artifacts.require("./TokenStorage.sol");

contract("TokenStorage", (accounts) => {
  it("should not have initial supply", () => {
    return TokenStorage.deployed().then((db) => {
      return db.getSupply();
    }).then((supply) => {
      assert.equal(supply.valueOf(), 0, "total supply is not 0");
    });
  });
  it("should have a supply of 10000 after explicitly setting to 10000", () => {
    return TokenStorage.deployed().then((db) => {
      db.addBalance(accounts[0], 0);
      db.getSupply().then((supply) => {
        assert.equal(supply.valueOf(), 10000, "total supply is not 10000");
      });
    });
  });
});
