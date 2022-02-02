/* SPDX-License-Identifier: apache-2.0 */
pragma solidity ^0.8.0;

/**
 * @title IPosChildToken
 * @dev This interface define the mandatory method enabling polygon bridging mechanism.
 * @notice This interface should be inherited to deploy on polygon POS network.
 */
interface IPosChildToken {
  function deposit(address user, bytes calldata depositData) external;
  function withdraw(uint256 amount) external;
}
