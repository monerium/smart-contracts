const EUR = artifacts.require("EUR");

module.exports = async function(exit) {

  console.log (`Deploying new EUR`);

  try {
    const instance = await EUR.new();
    console.log("Controller deployed to: ", instance.address, " tx: ", instance.transactionHash);
    exit(0);
  } catch (e) {
    exit(e);
  }
};
