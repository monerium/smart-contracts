const { SigningKey } = require("@ethersproject/signing-key");
var truffleAssert = require("truffle-assertions");

var EUR = artifacts.require("./EUR.sol");
var StandardController = artifacts.require("./StandardController.sol");
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var ERC677Lib = artifacts.require("./ERC677Lib.sol");
var MintableTokenLib = artifacts.require("./MintableTokenLib.sol");
var TokenStorageLib = artifacts.require("./TokenStorageLib.sol");
var SmartController = artifacts.require("./SmartController.sol");
var StandardController = artifacts.require("./StandardController.sol");
var ConstantSmartController = artifacts.require(
  "./ConstantSmartController.sol"
);
var BlacklistValidator = artifacts.require("./BlacklistValidator.sol");

var SmartTokenLib = artifacts.require("./SmartTokenLib.sol");
const AddressZero = "0x0000000000000000000000000000000000000000";

const wallet = {
  address: `0x77a3373AdCBe91E589D54F3a92Bb3F73F56686F4`,
  privateKey: `0x1a2a4798d8b0e070ceee86d09e0942ad489919450cda74d9ed4d9b90d0a3173a`,
};

contract("StandardController", (accounts) => {
  if (web3.version.network <= 100) {
    console.log("Skipping test on local network");
    return;
  }
  const ADMIN_ROLE =
    "0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775"; // SHA3("ADMIN_ROLE")
  const owner = accounts[0];
  const system = accounts[1];
  const admin = accounts[2];
  let controller;
  let eur;
  let mintableTokenLib;
  let smartTokenLib;
  let tokenStorageLib;
  let erc20Lib;
  let erc677Lib;
  let validator;

  before("setup system role eure", async () => {
    // Link
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

    await StandardController.link("TokenStorageLib", tokenStorageLib.address);
    await StandardController.link("ERC20Lib", erc20Lib.address);
    await StandardController.link("ERC677Lib", erc677Lib.address);

    await ConstantSmartController.link(
      "MintableTokenLib",
      mintableTokenLib.address
    );
    await ConstantSmartController.link("SmartTokenLib", smartTokenLib.address);
    await ConstantSmartController.link(
      "TokenStorageLib",
      tokenStorageLib.address
    );
    await ConstantSmartController.link("ERC20Lib", erc20Lib.address);
    await ConstantSmartController.link("ERC677Lib", erc677Lib.address);
    // Deploy
    eur = await EUR.new();
    validator = await BlacklistValidator.new();
    controller = await SmartController.new(
      AddressZero,
      validator.address,
      web3.utils.asciiToHex("EUR"),
      eur.address
    );
    await eur.setController(controller.address);
    await controller.addAdminAccount(admin);
    await controller.addSystemAccount(system);
    await controller.setMaxMintAllowance(1000000000000);
    await controller.setMintAllowance(system, 1000000000000, {
      from: admin,
    });
  });

  it("should permit a valid signature", async () => {
    const value = "1000000000000000000"; // 1e18
    const nonce = await controller.nonces(wallet.address); // Converted to string
    const deadline = Math.floor(Date.now() / 1000) + 60 * 60; // 1 hour from now
    const spender = admin;

    const digest = await controller.getPermitDigest(
      wallet.address,
      spender,
      value,
      nonce,
      deadline
    );
    const signingKey = new SigningKey(wallet.privateKey);
    const signature = signingKey.signDigest(digest);
    await controller.permit(
      wallet.address,
      spender,
      value,
      deadline,
      signature.v,
      signature.r,
      signature.s
    );
    const allowance = await controller.allowance(wallet.address, spender);
    assert.strictEqual(
      allowance.toString(),
      value,
      "allowance mismatch from signed data"
    );
  });

  it("should increment nonce after permit", async () => {
    const value = "1000000000000000000"; // 1e18
    const nonceBefore = await controller.nonces(wallet.address); // Converted to string
    const deadline = Math.floor(Date.now() / 1000) + 60 * 60; // 1 hour from now
    const spender = admin;

    const digest = await controller.getPermitDigest(
      wallet.address,
      spender,
      value,
      nonceBefore,
      deadline
    );
    const signingKey = new SigningKey(wallet.privateKey);
    const signature = signingKey.signDigest(digest);
    await controller.permit(
      wallet.address,
      spender,
      value,
      deadline,
      signature.v,
      signature.r,
      signature.s
    );
    const nonceAfter = await controller.nonces(wallet.address);
    assert.strictEqual(
      nonceAfter.toString(),
      nonceBefore.addn(1).toString(),
      "nonce did not increment after permit"
    );
  });

  it("should fail when spender address is sent twice", async () => {
    const value = "1000000000000000000"; // 1e18
    const spender = admin;
    const nonce = await controller.nonces(wallet.address); // Converted to string
    const deadline = Math.floor(Date.now() / 1000) + 60 * 60; // 1 hour from now

    const digest = await controller.getPermitDigest(
      wallet.address,
      spender,
      value,
      nonce,
      deadline
    );
    const signingKey = new SigningKey(wallet.privateKey);
    const signature = signingKey.signDigest(digest);
    await truffleAssert.reverts(
      controller.permit(
        spender,
        spender,
        value,
        deadline,
        signature.v,
        signature.r,
        signature.s
      ),
      "INVALID_SIGNER"
    );
  });

  it("should fail when wallet address is zero", async () => {
    const value = "1000000000000000000"; // 1e18
    const nonce = await controller.nonces(AddressZero); // Converted to string
    const deadline = Math.floor(Date.now() / 1000) + 60 * 60; // 1 hour from now
    const spender = admin;

    const digest = await controller.getPermitDigest(
      AddressZero,
      spender,
      value,
      nonce,
      deadline
    );
    const signingKey = new SigningKey(wallet.privateKey);
    const signature = signingKey.signDigest(digest);
    await truffleAssert.reverts(
      controller.permit(
        AddressZero,
        spender,
        value,
        deadline,
        signature.v,
        signature.r,
        signature.s
      ),
      "INVALID_SIGNER"
    );
  });

  it("should fail with an expired deadline", async () => {
    const value = "1000000000000000000"; // 1e18
    const nonce = await controller.nonces(wallet.address); // Converted to string
    const deadline = Math.floor(Date.now() / 1000) - 60; // 1 minute ago
    const spender = admin;
    const digest = await controller.getPermitDigest(
      wallet.address,
      spender,
      value,
      nonce,
      deadline
    );
    const signingKey = new SigningKey(wallet.privateKey);
    const signature = signingKey.signDigest(digest);

    await truffleAssert.reverts(
      controller.permit(
        wallet.address,
        spender,
        value,
        deadline,
        signature.v,
        signature.r,
        signature.s
      ),
      "PERMIT_DEADLINE_EXPIRED" // replace with the actual revert message you expect
    );
  });

  it("should not permit the same signature twice", async () => {
    const value = "1000000000000000000"; // 1e18
    const nonce = await controller.nonces(wallet.address); // Converted to string
    const deadline = Math.floor(Date.now() / 1000) + 60 * 60; // 1 hour from now
    const spender = admin;

    const digest = await controller.getPermitDigest(
      wallet.address,
      spender,
      value,
      nonce,
      deadline
    );
    const signingKey = new SigningKey(wallet.privateKey);
    const signature = signingKey.signDigest(digest);
    await controller.permit(
      wallet.address,
      spender,
      value,
      deadline,
      signature.v,
      signature.r,
      signature.s
    );
    const allowance = await controller.allowance(wallet.address, spender);
    assert.strictEqual(
      allowance.toString(),
      value,
      "allowance mismatch from signed data"
    );
    await truffleAssert.reverts(
      controller.permit(
        wallet.address,
        spender,
        value,
        deadline,
        signature.v,
        signature.r,
        signature.s
      ),
      "INVALID_SIGNER"
    );
  });
});
