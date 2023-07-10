var truffleAssert = require("truffle-assertions");
var MintableController = artifacts.require("./MintableController.sol");
var EthUtil = require("ethereumjs-util");

var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var ERC677Lib = artifacts.require("./ERC677Lib.sol");
var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var TokenStorageLib = artifacts.require("./TokenStorageLib.sol");

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

contract("MintableController", (accounts) => {
  if (web3.version.network <= 100) return;

  const owner = accounts[0];
  const system = accounts[1];
  const nonSystem = accounts[2];
  let controller;

  before("setup mintable controller", async () => {
    // Link
    tokenStorageLib = await TokenStorageLib.new();
    erc20Lib = await ERC20Lib.new();
    erc677Lib = await ERC677Lib.new();
    mintableTokenLib = await MintableTokenLib.new();
    await MintableController.link("TokenStorageLib", tokenStorageLib.address);
    await MintableController.link("ERC20Lib", erc20Lib.address);
    await MintableController.link("ERC677Lib", erc677Lib.address);
    await MintableController.link("MintableTokenLib", mintableTokenLib.address);
    // Deploy
    controller = await MintableController.new(AddressZero, 0, AddressZero);
    console.log(system);
    await controller.addSystemAccount(system);
    await controller.setMaxMintAllowance(1000000000000);
    await controller.addAdminAccount(nonSystem);
    await controller.setMintAllowance(system, 1000000000000, {
      from: nonSystem,
    });
  });

  const key = Buffer.from(
    "23f2ee33c522046e80b67e96ceb84a05b60b9434b0ee2e3ae4b1311b9f5dcc46",
    "hex"
  );
  const address = `0x${EthUtil.privateToAddress(key).toString("hex")}`;

  it("should start with zero tokens", async () => {
    const supply = await controller.totalSupply();
    assert.equal(supply.valueOf(), 0, "initial supply is not 0");
  });

  it("should fail adding system account from a non-owner address", async () => {
    await truffleAssert.reverts(
      controller.addSystemAccount(nonSystem, { from: system })
    );
  });

  it("should fail removing system account from a non-owner address", async () => {
    await truffleAssert.reverts(
      controller.removeSystemAccount(system, { from: system })
    );
  });

  it("should succeed in adding system account from an owner address", async () => {
    await controller.addSystemAccount(nonSystem, { from: owner });
    const success = await controller.isSystemAccount(nonSystem);
    assert.strictEqual(success, true, "unable to add system account");
  });

  it("should succeed in removing system account from an owner address", async () => {
    await controller.removeSystemAccount(system, { from: owner });
    const isSystem = await controller.isSystemAccount(system);
    assert.strictEqual(isSystem, false, "unable to remove system account");
  });

});
