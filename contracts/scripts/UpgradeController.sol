/* SPDX-License-Identifier: apache-2.0 */
pragma solidity 0.8.11;

import "../SmartController.sol";
import "../TokenFrontend.sol";

/**
 * @title UpgradeController
 * @notice Manages the upgrade process for the SmartController.
 * Deploys new contracts, transfers ownerships, and sets privileges and allowances limit.
 * @dev Can be deployed and operated by a development key, with the final ownership transferred as defined in function parameters.
 * Contains functions to launch the upgrade process and a transfer ownership.
 */
contract UpgradeController {
    address public controllerAddress;
    address public oldControllerAddress;
    address public frontendAddress;
    address internal deployer;

    constructor() {
        deployer = msg.sender;
    }

    /**
     * @notice Launches the upgrade process, deploying a new SmartController and transferring necessary ownerships and privileges.
     * @dev This contract can be used and deployed through the use of a development key.
     * The final ownership will be transferred to the address provided in the function parameters, not the development key used for deployment.
     * @param old_ The address of the old SmartController contract. Must be provided.
     * @param frontend_ The address of the TokenFrontend contract. Must be provided.
     * @param storage_ The address of the storage contract where the state is kept. Must be provided.
     * @param validator_ The address of the validator contract. Must be provided.
     * @param ticker_ The bytes3 ticker symbol for the token. Must be provided.
     * @param owner_ The final owner's address where ownership will be transferred to after the upgrade process. Must be provided.
     * @param system_ Optional system account's address, can be provided if there is a system account to add, otherwise address(0).
     * @param admin_ Optional admin account's address, can be provided if there is an admin account to add, otherwise address(0).
     * @param maxMintAllowance_ Optional maximum mint allowance, can be set to control minting limit, otherwise 0.
     */
    function launch(
        address old_,
        address frontend_,
        address storage_,
        address validator_,
        bytes3 ticker_,
        address owner_,
        address system_,
        address admin_,
        uint256 maxMintAllowance_
    ) public {
        require(
            deployer == msg.sender,
            "UpgradeController: Only deployer can launch"
        );
        oldControllerAddress = old_;
        frontendAddress = frontend_;
        SmartController oldController = SmartController(oldControllerAddress);
        TokenFrontend frontend = TokenFrontend(frontendAddress);

        // #1 Claiming ownership
        oldController.claimOwnership();
        frontend.claimOwnership();

        // #2 Deploying new controller
        SmartController controller = new SmartController(
            storage_,
            validator_,
            ticker_,
            frontendAddress
        );
        controllerAddress = address(controller);

        // #3 Transfering storage ownership to new controller
        oldController.transferStorageOwnership(controllerAddress);
        controller.claimStorageOwnership();

        // #4 Grant privileges
        controller.addSystemAccount(system_);
        controller.addAdminAccount(admin_);

        // #5 Set MintAllowance limit
        if (maxMintAllowance_ > 0) {
            controller.setMaxMintAllowance(maxMintAllowance_);
        }

        // #6 Connect the new controller to frontend
        frontend.setController(controllerAddress);

        // #7 Transfer ownership to owner_
        controller.transferOwnership(owner_);
        frontend.transferOwnership(owner_);
        oldController.transferOwnership(owner_);
    }

    function revertToLastController(
        address _controller,
        address _oldController,
        address _frontend,
        address _owner
    ) public {
        require(
            deployer == msg.sender,
            "UpgradeController: Only deployer can revert to LastController"
        );
        SmartController controller = SmartController(_controller);
        SmartController oldController = SmartController(_oldController);
        TokenFrontend frontend = TokenFrontend(_frontend);

        // #2 Transfering storage ownership to new controller
        oldController.transferStorageOwnership(_controller);
        controller.claimStorageOwnership();

        // #3 Connect the new controller to frontend
        frontend.setController(_controller);

        // #4 Transfer ownership to owner_
        controller.transferOwnership(_owner);
        frontend.transferOwnership(_owner);
        oldController.transferOwnership(_owner);
    }

    function transferOwnership(address newOwner) public {
        require(
            deployer == msg.sender,
            "UpgradeController: Only deployer can transfer ownership"
        );
        SmartController(controllerAddress).transferOwnership(newOwner);
        TokenFrontend(frontendAddress).transferOwnership(newOwner);
        SmartController(oldControllerAddress).transferOwnership(newOwner);
    }
}
