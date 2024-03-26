import hre from "hardhat";
import assert from "assert";

let token: any;
before("get factories", async function () {
  this.Token = await hre.ethers.getContractFactory("Token");
  this.BlacklistValidatorUpgradeable = await hre.ethers.getContractFactory("BlacklistValidatorUpgradeable");
});

it("deploy token", async function () {
  // Deploying the validator 
  const validator = await hre.upgrades.deployProxy(
    this.BlacklistValidatorUpgradeable,
    { kind: "uups" }
  );

  console.log("Validator deployed at:", validator.target);
  token = await hre.upgrades.deployProxy(
    this.Token,
    ["Monerium EUR emoney", "EURe", validator.target],
    { kind: "uups" }
  );
  assert((await token.name()) === "Monerium EUR emoney");
});

it("upgrade token to tokenV2", async function () {
  // Upgrading the token to version 2 using the upgradeProxy function.
  // The 'initializeV2' function is called as part of the upgrade process.
  const tokenv2: any = await hre.upgrades.upgradeProxy(token, this.Token);
  assert(tokenv2.target === token.target);
});
