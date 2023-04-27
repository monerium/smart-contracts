var SmartController = artifacts.require("./SmartController.sol");
var TokenFrontend = artifacts.require("./TokenFrontend.sol");

module.exports = async function(exit) {

  if (process.argv.length < 6) {
    console.log(`Usage: ${process.argv.join(" ")} <token> <account>`)
    exit(1);
  }

  const len = process.argv.length;
  const address = process.argv[len-2];
  const account = process.argv[len-1];
  console.log(`adding ${account}`);

  try {
    const token = await TokenFrontend.at(address);
    console.log(`token: ${address}`);
    const tx = await token.grantRole("0x12ff340d0cd9c652c747ca35727e68c547d0f0bfa7758d2e77f75acef481b4f2", account);
    console.log(tx);
    exit(0);
  } catch (e) {
    exit(e);
  }
}
