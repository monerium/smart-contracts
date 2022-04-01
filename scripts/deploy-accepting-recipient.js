const AcceptingRecipient = artifacts.require("AcceptingRecipient")

module.exports = callback => {
    AcceptingRecipient.new().then((instance) => {
    console.log("Token Deployed to : ", "https://goerli.etherscan.io/tx/" + instance.address)
    callback();
  }).catch(callback);
};
