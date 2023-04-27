var truffleAssert = require("truffle-assertions");
var Ownable = artifacts.require("Ownable");

const AddressZero = "0x0000000000000000000000000000000000000000";

contract("PolygonPosEUR", (accounts) => {
  if (web3.version.network <= 100) return;

  let token;

  before("setup PolygonPosEUR", async () => {
    owner = accounts[0];
    // Deploy
    token = await Ownable.new();
  });

  it("should be able to renounceOwnership", async () => {
    await token.renounceOwnership();
    await truffleAssert.fails(
      token.transferOwnership(accounts[1], { from: owner })
    );
  });
});
