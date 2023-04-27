/* SPDX-License-Identifier: apache-2.0 */
pragma solidity 0.8.11;

import "../SmartController.sol";
import "../TokenFrontend.sol";

contract UpgradeController {
    SmartController internal controller;

    function launch(
        address old_,
        address frontend_,
        address storage_,
        address validator_,
        bytes3 ticker_,
        address system_
    ) public {
        SmartController oldController = SmartController(old_);
        TokenFrontend frontend = TokenFrontend(frontend_);
        // #1 Claiming ownership
        oldController.claimOwnership();
        frontend.claimOwnership();
        // #2 Deploying new smart-contracts
        controller = new SmartController(
            storage_,
            validator_,
            ticker_,
            frontend_
        );
        // #3 Transfering storage ownership to new controller
        oldController.transferStorageOwnership(address(controller));
        controller.claimStorageOwnership();
        // #4 Grant system account privillege
        controller.addSystemAccount(system_);
        // #5 Connect the new controller to frontend
        frontend.setController(address(controller));
        // #6 Transfer ownership back to owner key (msg.sender)
        controller.transferOwnership(msg.sender);
        frontend.transferOwnership(msg.sender);
        oldController.transferOwnership(msg.sender);
    }

    function getController() public view returns (address) {
        return address(controller);
    }
}
