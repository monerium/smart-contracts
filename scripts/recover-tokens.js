var SmartController = artifacts.require("./SmartController.sol");
var TokenFrontend = artifacts.require("./TokenFrontend.sol");

module.exports = async function (exit) {
  if (process.argv.length < 11) {
    console.log(
      `Usage: ${process.argv.join(
        " "
      )} <frontend> <from> <to> <message> <signature>`
    );
    exit(1);
  }

  const len = process.argv.length;
  const frontend = process.argv[len - 5];
  const from = process.argv[len - 4];
  const to = process.argv[len - 3];
  const message = process.argv[len - 2];
  const signature = process.argv[len - 1];

  const hash = web3.sha3(
    `\x19Ethereum Signed Message:\n${message.length}${message}`
  );
  const h = `0x${hash.replace(/^0x/, "")}`;
  const sig = signature.replace(/^0x/, "");
  const r = `0x${sig.slice(0, 64)}`;
  const s = `0x${sig.slice(64, 128)}`;
  var v = web3.toDecimal(`0x${sig.slice(128, 130)}`);

  if (v < 27) v += 27;

  console.log(`frontend:\t${frontend}`);
  console.log(`from:\t\t${from}`);
  console.log(`to:\t\t${to}`);
  console.log(`message:\t${message}`);
  console.log(`hash:\t\t${h}`);
  console.log(`sig:\t\t${signature}`);
  // console.log(r);
  // console.log(s);
  // console.log(v);

  var tx;

  f = await TokenFrontend.at(frontend);
  console.log("recovering...");
  tx = await f.recover(from, to, h, v, r, s);
  console.log(tx);

  exit(0);
};
