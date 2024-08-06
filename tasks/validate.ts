import { task } from "hardhat/config";

// Function to validate the token implementation
async function validateTokenImplementation(ethers: any, upgrades: any) {
  const implementation = await ethers.getContractFactory("Token");
  // Validate the implementation without deploying
  await upgrades.validateImplementation(implementation, { kind: "uups" });
  console.log(`Token implementation validated successfully.`);
}

// Hardhat task definition
task("validate", "Validates the token implementation")
  .setAction(async (_, hre) => {
    const { ethers, upgrades } = hre;

    await validateTokenImplementation(ethers, upgrades);
  });

export default {};
