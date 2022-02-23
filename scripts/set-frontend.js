var StandardController = artifacts.require("./StandardController.sol");

module.exports = async function(exit) {

  if (process.argv.length < 6) {
    console.log(`Usage: ${process.argv.join(" ")} <controller> <frontend>`)
    exit(1);
  }

  const len = process.argv.length;
  const controller = process.argv[len-2];
  const frontend = process.argv[len-1];
  console.log(`controller ${controller}, frontend ${frontend}`);

  try {
    const standard = await StandardController.at(controller);
    const tx = await standard.setFrontend(frontend);
    console.log(tx);
    exit(0);
  } catch (e) {
    exit(e);
  }
}
