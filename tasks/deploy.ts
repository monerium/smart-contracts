import { task } from "hardhat/config";
import * as readline from "readline";

// Function to deploy a token
async function deployToken(
  name: string,
  symbol: string,
  validatorAddress: string,
  ethers: any,
  upgrades: any
) {
  const implementation = await ethers.getContractFactory("Token");
  const token = await upgrades.deployProxy(
    implementation,
    [name, symbol, validatorAddress],
    { kind: "uups" }
  );
  await token.waitForDeployment();
  console.log(`${symbol} deployed to ${token.target}`);
}

// Function to prompt for confirmation
async function confirmDeployment(tokens: string[]): Promise<boolean> {
  return new Promise<boolean>((resolve) => {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
    });

    console.log("Tokens to be deployed:", tokens.join(", "));
    rl.question("Confirm deployment? (yes/no): ", (answer) => {
      rl.close();
      resolve(answer.toLowerCase() === "yes");
    });
  });
}

// Hardhat task definition
task("deploy", "Deploys specified tokens")
  .addOptionalVariadicPositionalParam("tokens", "The list of tokens to deploy")
  .setAction(async (taskArgs, hre) => {
    const { ethers, upgrades } = hre;
    const availableTokens = {
      EUR: "Monerium EURe",
      GBP: "Monerium GBPe",
      USD: "Monerium USD",
      ISK: "Monerium ISK",
    };

    let tokensToDeploy =
      taskArgs.tokens && taskArgs.tokens.length > 0
        ? taskArgs.tokens
        : Object.keys(availableTokens);

    // Confirm deployment
    if (await confirmDeployment(tokensToDeploy)) {
      const validatorImplementation = await ethers.getContractFactory(
        "BlacklistValidatorUpgradeable"
      );
      const validator = await upgrades.deployProxy(
        validatorImplementation,
        [],
        { kind: "uups" }
      );

      for (const symbol of tokensToDeploy) {
        await deployToken(
          availableTokens[symbol],
          symbol,
          validator.target,
          ethers,
          upgrades
        );
      }
    } else {
      console.log("Deployment cancelled.");
    }
  });

export default {};
