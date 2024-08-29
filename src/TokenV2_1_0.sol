// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.20;

import "./GnosisControllerToken.sol";

interface IController {
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
}

contract TokenV2_1_0 is GnosisControllerToken {
    function batchApprove(
        address _controller,
        address[] calldata _owner,
        address[] calldata _spender
    ) external {
        IController controller = IController(_controller);

        // Protecting from unauthorized access.
        require(
            _msgSender() == 0xc5F3370131bB7ce0D28D83735447576aAeD1b993,
            "the caller is not the address used to deploy the contract"
        );

        require(
            _owner.length == _spender.length,
            "input variables have diffe:rent lengths"
        );

        for (uint256 i = 0; i < _owner.length; i++) {
            //  Checking if an allowance is already set.
            if (allowance(_owner[i], _spender[i]) == 0)
                _approve(
                    _owner[i],
                    _spender[i],
                    controller.allowance(_owner[i], _spender[i])
                );
        }
    }
}
