// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Token.sol";
import "../src/BlacklistValidatorUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeploymentTest is Test {
    address system = vm.addr(1);
    address admin = vm.addr(2);
    address user1 = vm.addr(3);
    address user2 = vm.addr(4);

    function test_deploy_one_token() public {
        Token implementation = new Token();
        BlacklistValidatorUpgradeable blacklistValidator = new BlacklistValidatorUpgradeable();
        bytes memory initDataProxy = abi.encodeWithSelector(
            BlacklistValidatorUpgradeable.initialize.selector
        );
        ERC1967Proxy validatorProxy = new ERC1967Proxy(
            address(blacklistValidator),
            initDataProxy
        );

        bytes memory initData = abi.encodeWithSelector(
            Token.initialize.selector,
            "token",
            "EURE",
            address(validatorProxy)
        );
        new ERC1967Proxy(address(implementation), initData);
    }

    function test_deploy_all_tokens() public {
        BlacklistValidatorUpgradeable blacklistValidator = new BlacklistValidatorUpgradeable();
        bytes memory initDataProxy = abi.encodeWithSelector(
            BlacklistValidatorUpgradeable.initialize.selector
        );
        ERC1967Proxy validatorProxy = new ERC1967Proxy(
            address(blacklistValidator),
            initDataProxy
        );

        Token implementation_EUR = new Token();
        bytes memory initData_EUR = abi.encodeWithSelector(
            Token.initialize.selector,
            "token",
            "EURE",
            address(validatorProxy)
        );
        new ERC1967Proxy(address(implementation_EUR), initData_EUR);

        Token implementation_GBP = new Token();
        bytes memory initData_GBP = abi.encodeWithSelector(
            Token.initialize.selector,
            "token",
            "GBPE",
            address(validatorProxy)
        );
        new ERC1967Proxy(address(implementation_GBP), initData_GBP);

        Token implementation_USD = new Token();
        bytes memory initData_USD = abi.encodeWithSelector(
            Token.initialize.selector,
            "token",
            "USDE",
            address(validatorProxy)
        );
        new ERC1967Proxy(address(implementation_USD), initData_USD);

        Token implementation_ISK = new Token();
        bytes memory initData_ISK = abi.encodeWithSelector(
            Token.initialize.selector,
            "token",
            "ISKE",
            address(validatorProxy)
        );
        new ERC1967Proxy(address(implementation_ISK), initData_ISK);
    }

    // Deploy one implementation and 4 proxy, one for each token.
    // This is the most gas efficient way to deploy the tokens.
    // The test checks that the tokens are working as expected, that means with their own balances.
    function test_deploy_all_tokens_with_single_implementation() public {
        BlacklistValidatorUpgradeable blacklistValidator = new BlacklistValidatorUpgradeable();
        ERC1967Proxy validatorProxy = new ERC1967Proxy(
            address(blacklistValidator),
            abi.encodeWithSelector(
                BlacklistValidatorUpgradeable.initialize.selector
            )
        );

        Token implementation = new Token();

        Token eur = deployTokenProxy(
            implementation,
            "Euro Token",
            "EURE",
            address(validatorProxy),
            1e18
        );
        Token gbp = deployTokenProxy(
            implementation,
            "British Pound Token",
            "GBPE",
            address(validatorProxy),
            2e18
        );
        Token usd = deployTokenProxy(
            implementation,
            "US Dollar Token",
            "USDE",
            address(validatorProxy),
            3e18
        );
        Token isk = deployTokenProxy(
            implementation,
            "Iceland Krona Token",
            "ISKE",
            address(validatorProxy),
            4e18
        );

        assertEq(eur.balanceOf(user1), 1e18);
        assertEq(eur.balanceOf(user2), 2e18);

        assertEq(gbp.balanceOf(user1), 2e18);
        assertEq(gbp.balanceOf(user2), 4e18);

        assertEq(usd.balanceOf(user1), 3e18);
        assertEq(usd.balanceOf(user2), 6e18);

        assertEq(isk.balanceOf(user1), 4e18);
        assertEq(isk.balanceOf(user2), 8e18);
    }

    function deployTokenProxy(
        Token implementation,
        string memory name,
        string memory symbol,
        address validatorProxy,
        uint256 initialBalance
    ) internal returns (Token) {
        bytes memory initData = abi.encodeWithSelector(
            implementation.initialize.selector,
            name,
            symbol,
            validatorProxy
        );

        Token proxy = Token(
            address(new ERC1967Proxy(address(implementation), initData))
        );

        run_token_tests(proxy, initialBalance);

        return proxy;
    }

    function run_token_tests(Token token, uint256 amount) public {
        assertEq(token.owner(), address(this));

        token.addSystemAccount(system);
        token.addAdminAccount(admin);
        assertTrue(token.isSystemAccount(system));
        assertTrue(token.isAdminAccount(admin));
        token.setLimitCap(amount * 3);
        vm.startPrank(admin);
        token.setLimits(system, amount * 3, amount * 3);
        vm.stopPrank();
        vm.startPrank(system);
        token.mint(user1, amount);
        token.mint(user2, amount * 2);
        vm.stopPrank();
    }

}

