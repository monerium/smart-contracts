var truffleAssert = require("truffle-assertions");
var Migrations = artifacts.require("Migrations.sol");

contract("Migrations", accounts => {

  let migrations;

  before("setup migration", async () => {
    migrations = await Migrations.new();
  });

  it("should initially be owned by first account", async () => {
    const owner = await migrations.owner()
    assert.equal(owner, accounts[0], "owner is not first account");
  });

  it("should fail to change ownership using a non-owner account", async () => {
    await truffleAssert.reverts(
      migrations.transferOwnership(accounts[1], {from: accounts[9]})
    );
  });

  it("should transfer ownership using an owner account", async () => {
    await migrations.transferOwnership(accounts[1]);
    const pendingOwner = await migrations.pendingOwner()
    assert.equal(pendingOwner, accounts[1], "unable to transfer ownership");
  });

  it("should fail to claim ownership using an non-pending owner", async () => {
    await migrations.transferOwnership(accounts[1]);
    await truffleAssert.reverts(
      migrations.claimOwnership({from: accounts[9]})
    );
  });

  it("should succeed in claiming ownership using a pending owner", async () => {
    await migrations.transferOwnership(accounts[1]);
    await migrations.claimOwnership({from: accounts[1]});
    const owner = await migrations.owner();
    assert.equal(owner, accounts[1], "unable to claim ownership");
    const pendingOwner = await migrations.pendingOwner();
    assert.equal(pendingOwner, 0x0, "pending owner not reset");
  });

  it("should allow new owner to update state", async () => {
    await migrations.setCompleted(10, {from: accounts[1]});
    const lastCompleted = await migrations.last_completed_migration();
    assert.equal(lastCompleted, 10, "unable to set last completed with new owner");
  });

  it("should should fail when updating state as the old owner", async () => {
    await truffleAssert.reverts(
      migrations.setCompleted(10, {from :accounts[0]})
    );
  });

});
