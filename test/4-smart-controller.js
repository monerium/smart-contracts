var truffleAssert = require("truffle-assertions");
var SmartController = artifacts.require("./SmartController.sol");
var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");
var ConstantValidator = artifacts.require("./ConstantValidator.sol");

var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var ERC677Lib = artifacts.require("./ERC677Lib.sol");
var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var TokenStorageLib = artifacts.require("./TokenStorageLib.sol");
var SmartTokenLib = artifacts.require("./SmartTokenLib.sol");

const AddressZero = "0x0000000000000000000000000000000000000000";
const hash = `0xa1de988600a42c4b4ab089b619297c17d53cffae5d5120d82d8a92d0bb3b78f2`;
const wallets = {
  "trust wallet": {
    address: `0xB0A6Ed7Fa5C6C5cc507840924591C1494eF47D04`,
    signature: `0xb5354ef622856f2acd9926752828d609b74471fa349891c70ec4512da5b7b8695418c39d82057dc09c480e8e65c5362327e882033e670e24b6a701983d93e18e1c`,
  },
  "ledger s nano": {
    address: `0x4A6bBDa876699420965147c26C3F3DF0bDc8eCab`,
    signature: `0xbad1a0d53be0e56724d877e053a199ca732c5e6e40d129c5a0980aa7d2c6582166af81969b23004ae81694e9518dcf39eb3af71d2847409376151f03465a0bf600`,
  },
  "meta mask": {
    address: `0xFB7ce0578B4dc16803A3CB04fA0b286fCFfFF76d`,
    signature: `0x1e1769b8ca9ca3d7d4b747f15336c185aac391c89cd9b9bfaf26f0a38631690e64ccd925382278c055c527a58ffab853a9734d889a6bae2b920544645f8ce4361c`,
  },
  trezor: {
    address: `0xbc89Bea7B6156be4514f5D429e30240F4C2600e4`,
    signature: `0x884d210ebc1437a56e4507c47a5fadcf1076ef366d37d23937a515e8af63075605fbb6be98a9c9dd41bfc68b57795c79375ef10e34a8bf90701a2200ff5cc59d1b`,
  },
};

contract("SmartController", (accounts) => {
  const owner = accounts[0];
  const system = accounts[1];
  const nonSystem = accounts[2];

  let controller;
  let validator;
  before("setup smart controller", async () => {
    // Link
    tokenStorageLib = await TokenStorageLib.new();
    erc20Lib = await ERC20Lib.new();
    erc677Lib = await ERC677Lib.new();
    mintableTokenLib = await MintableTokenLib.new();
    smartTokenLib = await SmartTokenLib.new();
    await SmartController.link("TokenStorageLib", tokenStorageLib.address);
    await SmartController.link("ERC20Lib", erc20Lib.address);
    await SmartController.link("ERC677Lib", erc677Lib.address);
    await SmartController.link("MintableTokenLib", mintableTokenLib.address);
    await SmartController.link("SmartTokenLib", smartTokenLib.address);
    // Deploy
    validator = await BlacklistValidator.new();
    controller = await SmartController.new(
      AddressZero,
      validator.address,
      web3.utils.asciiToHex("USD"),
      AddressZero
    );
    await controller.addSystemAccount(system);
    await controller.setValidator(validator.address);
    await controller.addAdminAccount(nonSystem, { from: owner });
    await controller.setMaxMintAllowance(1000000000000);
    await controller.setMintAllowance(system, 1000000000000, {
      from: nonSystem,
    });
  });

  it("should fail to construct if validator is the null address", async () => {
    await truffleAssert.fails(
      SmartController.new(AddressZero, AddressZero, "0x000", AddressZero)
    );
  });

  it("should construct if validator is a non-null address", async () => {
    const validator2 = await BlacklistValidator.new();
    const smart = await SmartController.new(
      AddressZero,
      validator2.address,
      "0x000",
      AddressZero
    );
    const initial = await smart.getValidator();
    assert.strictEqual(initial, validator2.address, "validator should be set");
  });

  it("should start with zero tokens", async () => {
    const supply = await controller.totalSupply();
    assert.equal(supply.valueOf(), 0, "initial supply is not 0");
  });

  it("should fail setting a new validator from a non-system account", async () => {
    const initial = await controller.getValidator();
    const constantValidator = await ConstantValidator.new(true);
    assert.notEqual(
      constantValidator.address,
      initial,
      "initial validator should not be constant validator"
    );
    await truffleAssert.reverts(
      controller.setValidator(constantValidator.address, { from: nonSystem })
    );
    const post = await controller.getValidator();
    assert.strictEqual(post, initial, "validator should not have changed");
  });

  it("should succeed setting new validator from a system account", async () => {
    const initial = await controller.getValidator();
    const constantValidator = await ConstantValidator.new(true);
    assert.notEqual(
      constantValidator.address,
      initial,
      "initial validator should not be constant validator"
    );
    await controller.setValidator(constantValidator.address, { from: owner });
    const post = await controller.getValidator();
    assert.strictEqual(
      post,
      constantValidator.address,
      "validator should be set to constant validator"
    );
  });
});
