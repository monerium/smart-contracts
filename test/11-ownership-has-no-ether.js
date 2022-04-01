const HasNoEther = artifacts.require('HasNoEther');
const ForceEther = artifacts.require('ForceEther');
var truffleAssert = require('truffle-assertions');

const toPromise = func =>
  (...args) =>
    new Promise((resolve, reject) =>
      func(...args, (error, data) => error ? reject(error) : resolve(data)));

contract('HasNoEther', function (accounts) {
  const amount = web3.utils.toWei('1', 'ether');

  it('should be constructorable', async function () {
    await HasNoEther.new();
  });

  it('should not accept ether in constructor', async function () {
    await truffleAssert.fails(
      HasNoEther.new({ value: amount })
    );
  });

  it('should not accept ether', async function () {
    let hasNoEther = await HasNoEther.new();

    await truffleAssert.fails(
      toPromise(web3.eth.sendTransaction)({
        from: accounts[1],
        to: hasNoEther.address,
        value: amount,
      }),
    );
  });

  it('should allow owner to reclaim ether', async function () {
    // Create contract
    let hasNoEther = await HasNoEther.new();
    const startBalance = await web3.eth.getBalance(hasNoEther.address);
    assert.equal(startBalance, 0);

    // Force ether into it
    let forceEther = await ForceEther.new({ value: amount });
    await forceEther.destroyAndSend(hasNoEther.address);
    const forcedBalance = await web3.eth.getBalance(hasNoEther.address);
    assert.equal(forcedBalance, amount);

    // Reclaim
    const ownerStartBalance = await web3.eth.getBalance(accounts[0]);
    await hasNoEther.reclaimEther();
    const ownerFinalBalance = await web3.eth.getBalance(accounts[0]);
    const finalBalance = await web3.eth.getBalance(hasNoEther.address);
    assert.equal(finalBalance, 0);
    assert.isAbove(parseInt(ownerFinalBalance, 10), parseInt(ownerStartBalance, 10));
  });

  it('should allow only owner to reclaim ether', async function () {
    // Create contract
    let hasNoEther = await HasNoEther.new({ from: accounts[0] });

    // Force ether into it
    let forceEther = await ForceEther.new({ value: amount });
    await forceEther.destroyAndSend(hasNoEther.address);
    const forcedBalance = await web3.eth.getBalance(hasNoEther.address);
    assert.equal(forcedBalance, amount);

    // Reclaim
    await truffleAssert.reverts(
      hasNoEther.reclaimEther({ from: accounts[1] })
    );
  });
});
