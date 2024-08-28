// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Token.sol";
import "../src/TokenV2_1_0.sol";
import "../src/BlacklistValidatorUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract TokenV2_1_0Test is Test {
    Token public token;
    ERC1967Proxy public proxy;
    address public deployerAddress;

    function deployToken() public returns (Token) {
        Token implementation = new Token();
        BlacklistValidatorUpgradeable blacklistValidator = new BlacklistValidatorUpgradeable();

        // Deploy the validator proxy contract
        ERC1967Proxy validatorProxy = new ERC1967Proxy(
            address(blacklistValidator),
            ""
        );

        // Initialize the Token with the proxy
        bytes memory initData = abi.encodeWithSelector(
            Token.initialize.selector,
            "token",
            "EURe",
            address(validatorProxy)
        );
        ERC1967Proxy newProxy = new ERC1967Proxy(
            address(implementation),
            initData
        );
        return Token(address(newProxy));
    }

    function setUp() public {
        // Deploy the initial implementation contract
        Token implementation = new Token();
        BlacklistValidatorUpgradeable blacklistValidator = new BlacklistValidatorUpgradeable();

        // Deploy the validator proxy contract
        ERC1967Proxy validatorProxy = new ERC1967Proxy(
            address(blacklistValidator),
            ""
        );

        // Initialize the Token with the proxy
        bytes memory initData = abi.encodeWithSelector(
            Token.initialize.selector,
            "token",
            "EURe",
            address(validatorProxy)
        );
        proxy = new ERC1967Proxy(address(implementation), initData);

        // Cast the proxy address to the Token interface
        token = Token(address(proxy));
        deployerAddress = address(0xc5F3370131bB7ce0D28D83735447576aAeD1b993);
    }

    function testUpgradeToV2() public {
        // Verify initial state
        assertEq(token.name(), "token");
        assertEq(token.symbol(), "EURe");

        // Deploy the new TokenV2 implementation contract
        TokenV2_1_0 newImplementation = new TokenV2_1_0();

        // Empty data since there is no initialize method in TokenV2_1_0
        bytes memory data = "";
        // Upgrade the proxy to use the new implementation contract
        token.upgradeToAndCall(address(newImplementation), data);

        // Cast the proxy address to the TokenV2 interface
        TokenV2_1_0 upgradedToken = TokenV2_1_0(address(proxy));

        // Verify the upgrade was successful
        assertEq(upgradedToken.name(), "token");
        assertEq(upgradedToken.symbol(), "EURe");
    }

    function testBatchApprove() public {
        // Deploy the new TokenV2 implementation contract
        TokenV2_1_0 newImplementation = new TokenV2_1_0();
        // using a token as 'source' for the batchApprove function. In production we will use the last V1 controller
        Token source = deployToken();

        // Upgrade the proxy to use the new implementation contract
        bytes memory data = "";
        token.upgradeToAndCall(address(newImplementation), data);

        // Cast the proxy address to the TokenV2 interface
        TokenV2_1_0 upgradedToken = TokenV2_1_0(address(proxy));

        // Create dummy addresses and values for testing
        address[] memory owners = new address[](3);
        address[] memory spenders = new address[](3);

        owners[0] = address(0x123);
        owners[1] = address(0x456);
        owners[2] = address(0x789);

        spenders[0] = address(0xabc);
        spenders[1] = address(0xdef);
        spenders[2] = address(0xded);

        // Set initial allowance
        vm.prank(owners[0]);
        source.approve(spenders[0], 1e18);
        vm.prank(owners[1]);
        source.approve(spenders[1], 2e18);
        vm.prank(owners[2]);
        source.approve(spenders[2], 3e18);
        // Call batchApprove function
        vm.prank(deployerAddress);
        upgradedToken.batchApprove(address(source), owners, spenders);

        // Verify the approvals
        assertEq(upgradedToken.allowance(owners[0], spenders[0]), 1e18);
        assertEq(upgradedToken.allowance(owners[1], spenders[1]), 2e18);
        assertEq(upgradedToken.allowance(owners[2], spenders[2]), 3e18);
    }

    function test_BatchApproveShouldFailIfNotOwner() public {
        // Deploy the new TokenV2 implementation contract
        TokenV2_1_0 newImplementation = new TokenV2_1_0();
        // using a token as 'source' for the batchApprove function. In production we will use the last V1 controller
        Token source = deployToken();

        // Upgrade the proxy to use the new implementation contract
        bytes memory data = "";
        token.upgradeToAndCall(address(newImplementation), data);

        // Cast the proxy address to the TokenV2 interface
        TokenV2_1_0 upgradedToken = TokenV2_1_0(address(proxy));

        // Create dummy addresses and values for testing
        address[] memory owners = new address[](3);
        address[] memory spenders = new address[](3);

        owners[0] = address(0x123);
        owners[1] = address(0x456);
        owners[2] = address(0x789);

        spenders[0] = address(0xabc);
        spenders[1] = address(0xdef);
        spenders[2] = address(0xded);

        // Set initial allowance
        vm.prank(owners[0]);
        source.approve(spenders[0], 1e18);
        vm.prank(owners[1]);
        source.approve(spenders[1], 2e18);
        vm.prank(owners[2]);
        source.approve(spenders[2], 3e18);

        // Call batchApprove function
        vm.prank(address(0x123));
        vm.expectRevert(
            "the caller is not the address used to deploy the contract"
        );
        upgradedToken.batchApprove(address(source), owners, spenders);
    }

    function test_BatchApprove_withAlreadySetAllowance() public {
        // Deploy the new TokenV2 implementation contract
        TokenV2_1_0 newImplementation = new TokenV2_1_0();
        // using a token as 'source' for the batchApprove function. In production we will use the last V1 controller
        Token source = deployToken();

        // Upgrade the proxy to use the new implementation contract
        bytes memory data = "";
        token.upgradeToAndCall(address(newImplementation), data);

        // Cast the proxy address to the TokenV2 interface
        TokenV2_1_0 upgradedToken = TokenV2_1_0(address(proxy));

        // Create dummy addresses and values for testing
        address[] memory owners = new address[](3);
        address[] memory spenders = new address[](3);

        owners[0] = address(0x123);
        owners[1] = address(0x456);
        owners[2] = address(0x789);

        spenders[0] = address(0xabc);
        spenders[1] = address(0xdef);
        spenders[2] = address(0xded);

        // Set initial allowance in source contract
        vm.prank(owners[0]);
        source.approve(spenders[0], 1e18);
        vm.prank(owners[1]);
        source.approve(spenders[1], 2e18);
        vm.prank(owners[2]);
        source.approve(spenders[2], 3e18);

        // set inital allowance in proxy
        vm.prank(owners[0]);
        upgradedToken.approve(spenders[0], 666);

        // Call batchApprove function
        vm.prank(deployerAddress);
        upgradedToken.batchApprove(address(source), owners, spenders);

        // Verify the approvals
        assertEq(upgradedToken.allowance(owners[0], spenders[0]), 666);
        assertEq(upgradedToken.allowance(owners[1], spenders[1]), 2e18);
        assertEq(upgradedToken.allowance(owners[2], spenders[2]), 3e18);
    }
}
