var ISK = artifacts.require("./ISK.sol");

module.exports = async function (exit) {
  if (process.argv.length < 5) {
    console.log(`Usage: ${process.argv.join(" ")} <account>`);
    exit(1);
  }

  const len = process.argv.length;
  const address = process.argv[len - 1];
  console.log(`controller ${address}`);

  try {
    const frontend = await ISK.deployed();
    const tx = await frontend.setController(address);
    console.log(tx);
    exit(0);
  } catch (e) {
    exit(e);
  }
};
