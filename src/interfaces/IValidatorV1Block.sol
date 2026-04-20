// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.20;

interface IValidatorV1Block {
    function isV1Blocked(address account) external view returns (bool);
    function getV1BlockedCount() external view returns (uint256);
}
