var MintableController = artifacts.require("./MintableController.sol");

const controller = MintableController.at(MintableController.address);

contract('MintableController', accounts => {

  it("should start with zero tokens", async () => {
    const supply = await controller.totalSupply();
    assert.equal(supply.valueOf(), 0, "initial supply is not 0");  
  });

  it("should mint 48000 new tokens", async () => {
    await controller.mint(48000, {from: accounts[0]});
    const balance = await controller.balanceOf(accounts[0]);
    assert.equal(balance.valueOf(), 48000, "did not mint 48000 tokens");
  });

  it("should burn 1700 tokens", async () => {
    await controller.burn(1700, {from: accounts[0]});
    const balance = await controller.balanceOf(accounts[0]);
    assert.equal(balance.valueOf(), 46300, "remaining tokens should be 46300");
  });

});
