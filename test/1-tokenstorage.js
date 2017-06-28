var TokenStorage = artifacts.require("./TokenStorage.sol");

contract("TokenStorage", (accounts) => {
  it("should not have initial supply", () => {
    return TokenStorage.deployed().then((db) => {
      return db.getSupply();
    }).then((supply) => {
      assert.equal(supply.valueOf(), 0, "total supply is not 0");
    });
  });
  it("should have a supply of 85000 after manually increasing to 85000", () => {
    var db;
    return TokenStorage.deployed().then((_db) => {
      db = _db;
      return db.addBalance(accounts[0], 85000);
    }).then(
      () => db.getSupply()
    ).then((supply) => {
      assert.equal(supply.valueOf(), 85000, "total supply is not 85000");
    });
  });
  it("should have a supply of 73000 after explicitly reducing from 85000", () => {
    var db;
    return TokenStorage.deployed().then((_db) => {
      db = _db;
      return db.subBalance(accounts[0], 12000);
    }).then(
      () => db.getSupply()
    ).then((supply) => {
      assert.equal(supply.valueOf(), 73000, "total supply is not 73000");
    });
  });
  it("should have a cumulative balance of 73000 in the first account", () => {
    return TokenStorage.deployed().then((db) => {
      return db.getBalance(accounts[0]);
    }).then((balance) => {
      assert.equal(balance.valueOf(), 73000, "balance in account one is not 73000");
    });
  });
  it("should have a balance of 30000 in second account", () => {
    var db;
    return TokenStorage.deployed().then((_db) => {
      db = _db;
      return db.addBalance(accounts[1], 30000);
    }).then(
      () => db.getBalance(accounts[1])
    ).then((balance) => {
      assert.equal(balance.valueOf(), 30000, "balance is not 30000");
    });
  });
  it("should fail when minting from a non-owner account", () => {
    var db;
    var startSupply, endSupply;
    return TokenStorage.deployed().then((_db) => {
      db = _db;
      return db.getSupply();
    }).then((supply) => {
      startSupply = supply.valueOf();
    }).then(
      () => db.addBalance(accounts[3], 1000000, {from: accounts[4]})
    ).then(
      () => db.getSupply()
    ).then((supply) => {
      endSupply = supply.valueOf()
      assert.notEqual(endSupply-startSupply, 1000000, "new supply shouldn't be 1000000");
    });
  });
});
