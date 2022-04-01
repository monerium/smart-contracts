var truffleAssert = require('truffle-assertions');
var PolygonPosEUR = artifacts.require("./PolygonPosEUR.sol");
var SmartController = artifacts.require("./SmartController.sol");
var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");
var SimpleToken = artifacts.require("./SimpleToken.sol");

var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var SmartTokenLib = artifacts.require("./SmartTokenLib.sol");
var TokenStorageLib = artifacts.require("./TokenStorageLib.sol");
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var ERC677Lib = artifacts.require("./ERC677Lib.sol");

const abiEncoded100uint = "0x0000000000000000000000000000000000000000000000000000000000000064";
const AddressZero = "0x0000000000000000000000000000000000000000";

contract("PolygonPosEUR", accounts => {

  if (web3.version.network <= 100) return;

  let ppeur;
  let owner;
  let depositor;

  before("setup PolygonPosEUR", async () => {
    owner = accounts[0]
    depositor = accounts[1];
    // Library Linkage
    mintableTokenLib = await MintableTokenLib.new();
    smartTokenLib = await SmartTokenLib.new();
    tokenStorageLib = await TokenStorageLib.new();
    erc20Lib = await ERC20Lib.new();
    erc677Lib = await ERC677Lib.new();
    await SmartController.link("MintableTokenLib", mintableTokenLib.address);
    await SmartController.link("SmartTokenLib", smartTokenLib.address);
    await SmartController.link("TokenStorageLib", tokenStorageLib.address);
    await SmartController.link("ERC20Lib", erc20Lib.address);
    await SmartController.link("ERC677Lib", erc677Lib.address);
    // Deploy
    ppeur = await PolygonPosEUR.new(depositor);
    blacklist = await BlacklistValidator.new();
    controller = await SmartController.new(AddressZero, blacklist.address, web3.utils.asciiToHex("EUR"), ppeur.address);
    await ppeur.setController(controller.address);
    await controller.addSystemAccount(ppeur.address);
  });

  it("shouldn't be able to deposit without DEPOSITOR role", async () => {
    await truffleAssert.reverts(
      ppeur.deposit(accounts[0], abiEncoded100uint ,{from: accounts[0]})
    );
  });

  it("should be able to deposit with DEPOSITOR ROLE", async () => {
    const isSystem = await controller.isSystemAccount(ppeur.address);
    assert.strictEqual(isSystem, true, "PolygonPosEUR instance should be system account");

    const balanceBefore = await ppeur.balanceOf(accounts[0]);
    await ppeur.deposit(accounts[0], abiEncoded100uint, {from: accounts[1]});
    const balanceAfter = await ppeur.balanceOf(accounts[0]);
    assert.strictEqual(balanceBefore.toNumber() + 100, balanceAfter.toNumber(), "should be equal if mint succeded");
  });

  it("should be able to withdraw", async () => {
    const balanceBefore = await ppeur.balanceOf(accounts[0]);
    await ppeur.withdraw(100, {from: accounts[0]});
    const balanceAfter = await ppeur.balanceOf(accounts[0]);
    assert.strictEqual(balanceBefore.toNumber() - 100, balanceAfter.toNumber(), "should be equal if withdraw succeded");
  })

});
