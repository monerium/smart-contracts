var SmartController = artifacts.require("./SmartController.sol");
var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");

const controller = SmartController.at(SmartController.address);

contract('SmartController', (accounts) => {

  it("should start with zero tokens", async () => {
    const supply = await controller.totalSupply();
    assert.equal(supply.valueOf(), 0, "initial supply is not 0");  
  });

  it("should mint 88000 new tokens", async () => {
    await controller.mint(88000, {from: accounts[0]});
    const balance = await controller.balanceOf(accounts[0])
    assert.equal(balance.valueOf(), 88000, "did not mint 88000 tokens");
  });

  it("should transfer 3400 tokens to second account", async () => {
    await controller.transfer(accounts[1], 3400, {from: accounts[0]});
    const balance = await controller.balanceOf(accounts[1])
    assert.equal(balance.valueOf(), 3400, "did not transfer 3400 tokens"); 
  });

  it("should should fail transferring 1840 tokens from a blacklisted account", async () => {
    const validator = await controller.getValidator();
    BlacklistValidator.at(validator).ban(accounts[2]);
    try {
      await controller.transfer(accounts[3], 1840, {from: accounts[2]});
    } catch { 
      return;
    }
    assert.fail("No Error", new Error(), "This operation should fail");
  });

});
