var SmartController = artifacts.require("./SmartController.sol");
var TokenFrontend = artifacts.require("./TokenFrontend.sol");

module.exports = async function(exit) {

  if (process.argv.length < 10) {
    console.log(`Usage: ${process.argv.join(" ")} <smart-controller> <frontend> <account> <signature>`)
    exit(1);
  }

  const len = process.argv.length;
  const controller = process.argv[len-4];
  const frontend = process.argv[len-3];
  const account = process.argv[len-2];
  const signature = process.argv[len-1];
  const tokens = 10;

  const hash = web3.sha3("\x19Ethereum Signed Message:\n0");
  const sig = signature.replace(/^0x/, '');
  const r = `0x${sig.slice(0, 64)}`;
  const s = `0x${sig.slice(64, 128)}`;
  var v = web3.toDecimal(`0x${sig.slice(128, 130)}`);

  if (v < 27) v += 27;

  // console.log(r);
  // console.log(s);
  // console.log(v);

  var tx;

  try {
    const c = await SmartController.at(controller);
    const f = await TokenFrontend.at(frontend);
    const initial = await f.balanceOf(account);
    
    console.log("minting...");
    tx = await c.mintTo(account, web3.toWei(tokens, 'ether'));
    console.log(tx);

    const post = await f.balanceOf(account);
    if (post.toNumber() != initial.toNumber() + tokens*10**18) {
      exit(`did not mint correct amount ${post.toNumber()} != ${initial.toNumber()} + ${tokens*10**18}`);
    }

    console.log("burning...");
    tx = await c.burnFrom(account, web3.toWei(tokens, 'ether'), hash, v, r, s);
    console.log(tx);

    const end = await f.balanceOf(account);
    if (end.toNumber() != initial.toNumber()) {
      exit(`did not burn correct amount ${end.toNumber()} != ${initial.toNumber()}`);
    }


    exit(0);
  } catch (e) {
    exit(e);
  }
}
