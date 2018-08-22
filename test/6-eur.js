var EUR = artifacts.require("./EUR.sol");

const eur = EUR.at(EUR.address);

contract("EUR", accounts => {

  it("should start with zero tokens", async () => {
    const supply = await eur.totalSupply();
    assert.equal(supply.valueOf(), 0, "initial supply is not 0");  
  });

});

