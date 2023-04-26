const RejectingRecipient = artifacts.require("RejectingRecipient");

module.exports = (callback) => {
  RejectingRecipient.new()
    .then((instance) => {
      console.log(
        "Token Deployed to : ",
        "https://goerli.etherscan.io/tx/" + instance.address
      );
      callback();
    })
    .catch(callback);
};
