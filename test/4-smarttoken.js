var SmartController = artifacts.require("./SmartController.sol");
var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");

const controller = SmartController.at(SmartController.address);
const address = `0xB0A6Ed7Fa5C6C5cc507840924591C1494eF47D04`;
const hash = `0xa1de988600a42c4b4ab089b619297c17d53cffae5d5120d82d8a92d0bb3b78f2`;
const sig = `b5354ef622856f2acd9926752828d609b74471fa349891c70ec4512da5b7b8695418c39d82057dc09c480e8e65c5362327e882033e670e24b6a701983d93e18e1c`;

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
    assert.fail("succeeded", "fail", "transfer was supposed to fail");
  });

  it("should be able to recover the balance of a known address to a new address", async () => {
    await controller.transfer(address, 13, {from: accounts[0]});

    const r = `0x${sig.slice(0, 64)}`;
    const s = `0x${sig.slice(64, 128)}`;
    var v = web3.toDecimal(`0x${sig.slice(128, 130)}`);

    if (v < 27) v += 27;
    assert(v == 27 || v == 28);

    await controller.recover(address, address[5], hash, v, r, s);
    const balanceFrom = await controller.balanceOf(address);
    assert.equal(balanceFrom.valueOf(), 0, "did not recover 13 tokens");
    const balanceTo = await controller.balanceOf(address[5]);
    assert.equal(balanceTo.valueOf(), 13, "did not recover 13 tokens");

  })

});
