var EUR = artifacts.require("./EUR.sol");

contract("EUR", (accounts) => {
  it("should start with zero tokens", () => {
    return EUR.deployed().then(
      (token) => token.totalSupply()
    ).then((supply) => {
      assert.equal(supply.valueOf(), 0, "initial supply is not 0");  
    });
  });
});

