// SPDX-License-Identifier: APACHE-2.0
pragma solidity 0.8.20;

interface IERC677Recipient {
    /**
     * @dev Receives notification from [ERC677] transferAndCall.
     * @param from Sender address.
     * @param amount Number of tokens.
     * @param data Additional data.
     */
    function onTokenTransfer(
        address from,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}
