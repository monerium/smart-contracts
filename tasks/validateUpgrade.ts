import { task } from "hardhat/config";

// Function to validate an upgrade for a token proxy
async function validateTokenUpgrade(proxyAddress: string, ethers: any, upgrades: any) {
  const tokenProxy = await ethers.getContractAt("Token", proxyAddress);
  const name = await tokenProxy.name();
  const symbol = await tokenProxy.symbol();
  process.stdout.write(`Validating upgrade for Token at ${proxyAddress} (Name: ${name}, Symbol: ${symbol}) `);

  const newImplementation = await ethers.getContractFactory("Token");
  await upgrades.validateUpgrade(proxyAddress, newImplementation, { kind: "uups" });
  console.log("✅");
}

// Hardhat task definition
task("validateUpgrade", "Validates upgrades for specified token proxies")
  .addVariadicPositionalParam("addresses", "The list of proxy addresses to validate upgrades for")
  .setAction(async (taskArgs, hre) => {
    const { ethers, upgrades } = hre;
    const addresses = taskArgs.addresses;

    if (!addresses || addresses.length === 0) {
      console.log("No proxy addresses provided. Example usage: npx hardhat validateUpgrade 0x1... 0x2...");
      return;
    }

    for (const address of addresses) {
      await validateTokenUpgrade(address, ethers, upgrades);
    }
  });

export default {};
