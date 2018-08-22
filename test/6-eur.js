var EUR = artifacts.require("./EUR.sol");

const eur = EUR.at(EUR.address);

contract("EUR", accounts => {

  it("should start with zero tokens", async () => {
    const supply = await eur.totalSupply();
    assert.equal(supply.valueOf(), 0, "initial supply is not 0");  
  });

  it("should be claimable", async () => {
    await eur.transferOwnership(accounts[1]);
    const owner0 = await eur.owner();
    assert.equal(owner0, accounts[0], "not original owner");
    await eur.claimOwnership({from: accounts[1]});
    const owner1 = await eur.owner();
    assert.equal(owner1, accounts[1], "ownership claim failed");
  });

});

