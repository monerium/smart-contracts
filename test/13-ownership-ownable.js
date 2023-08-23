var truffleAssert = require("truffle-assertions");
var Ownable = artifacts.require("Ownable");

const AddressZero = "0x0000000000000000000000000000000000000000";

contract("PolygonPosEUR", (accounts) => {
  if (web3.version.network <= 100) return;


  before("setup PolygonPosEUR", async () => {
    owner = accounts[0];
    // Deploy
    token = await Ownable.new();
  });


});
