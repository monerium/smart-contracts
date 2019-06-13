var USD = artifacts.require("./USD.sol");

module.exports = async function(exit) {

  if (process.argv.length != 5) {
    console.log(`Usage: ${process.argv.join(" ")} <account>`)
    exit(1);
  }

  const address = process.argv[4];
  console.log(`controller ${address}`);

  try {
    const frontend = await USD.deployed();
    const tx = await frontend.setController(address);
    console.log(tx);
    exit(0);
  } catch (e) {
    exit(e);
  }
}
