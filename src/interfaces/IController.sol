// SPDX-License-Identifier: APACHE-2.0
pragma solidity 0.8.20;

interface IController {
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
}
