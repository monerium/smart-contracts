/* SPDX-License-Identifier: apache-2.0 */
pragma solidity 0.8.11;

import "./SmartController.sol";
import "./EUR.sol";

contract NewControllerAndBridgeFrontend {
  SmartController internal controller;
  EUR internal bridge;

  function launch(address old_, address frontend_, address storage_, address validator_, bytes3 ticker_) public {
    SmartController oldController = SmartController(old_);
    EUR frontend = EUR(frontend_);
    // #1 Claiming ownership
    oldController.claimOwnership();
    frontend.claimOwnership();
    // #2 Deploying new smart-contracts
    bridge = new EUR();
    controller = new SmartController(storage_, validator_, ticker_, frontend_);
    // #3 Transfering storage ownership to new controller
    oldController.transferStorageOwnership(address(controller));
    controller.claimStorageOwnership();
    // #4 Connect the new controller to both frontend
    controller.setBridgeFrontend(address(bridge), "Polygon Bridge");
    frontend.setController(address(controller));
    bridge.setController(address(controller));
    // #5 Transfer ownership back to owner key (msg.sender)
    controller.transferOwnership(msg.sender);
    frontend.transferOwnership(msg.sender);
    bridge.transferOwnership(msg.sender);
    oldController.transferOwnership(msg.sender);
  }

  function getBridge() public view returns(address){
    return address(bridge);
  }

  function getController() public view returns(address){
    return address(controller);
  }
}
