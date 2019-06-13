var StandardController = artifacts.require("./StandardController.sol");

module.exports = async function(exit) {

  if (process.argv.length != 6) {
    console.log(`Usage: ${process.argv.join(" ")} <controller> <frontend>`)
    exit(1);
  }

  const controller = process.argv[4];
  const frontend = process.argv[5];
  console.log(`controller ${controller}, frontend ${frontend}`);

  try {
    const standard = StandardController.at(controller);
    const tx = await standard.setFrontend(frontend);
    console.log(tx);
    exit(0);
  } catch (e) {
    exit(e);
  }
}
