var TokenFrontend = artifacts.require("./TokenFrontend.sol");

module.exports = async function (exit) {
  if (process.argv.length < 7) {
    console.log(`Usage: ${process.argv.join(" ")} <token> <address> <amount>`);
    exit(1);
  }

  const len = process.argv.length;
  const tokenAddress = process.argv[len - 3];
  const recipientAddress = process.argv[len - 2];
  const amount = process.argv[len - 1];

  console.log(`Token: ${tokenAddress}, Recipient: ${recipientAddress}, Amount: ${amount}`);

  try {
    const frontend = await TokenFrontend.at(tokenAddress);

    const tx = await frontend.mintTo(recipientAddress, amount);
    console.log("Mint transaction: ");
    console.log(tx);
    
    exit(0);
  } catch (e) {
    console.error(e);
    exit(e);
  }
};
