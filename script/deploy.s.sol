// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Token.sol";
import "../src/ControllerToken.sol";
import "../src/BlacklistValidatorUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract All is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        BlacklistValidatorUpgradeable blacklistValidator = new BlacklistValidatorUpgradeable();
        ERC1967Proxy validatorProxy = new ERC1967Proxy(
            address(blacklistValidator),
            abi.encodeWithSelector(BlacklistValidatorUpgradeable.initialize.selector)
        );

        Token implementation = new Token();

        deployTokenProxy(implementation, "Monerium EUR emoney", "EURe", address(validatorProxy));
        deployTokenProxy(implementation, "Monerium GBP emoney", "GBPe", address(validatorProxy));
        deployTokenProxy(implementation, "Monerium ISK emoney", "ISKe", address(validatorProxy));
        deployTokenProxy(implementation, "Monerium USD emoney", "USDe", address(validatorProxy));

        vm.stopBroadcast();
    }

    function deployTokenProxy(
        Token implementation,
        string memory name,
        string memory symbol,
        address validatorProxy
    ) internal {
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeWithSelector(
                implementation.initialize.selector,
                name,
                symbol,
                validatorProxy
            )
        );

        console.log("Deployed", symbol, "at", address(proxy));
    }
}

contract ControllerEUR is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        BlacklistValidatorUpgradeable blacklistValidator = new BlacklistValidatorUpgradeable();
        ERC1967Proxy validatorProxy = new ERC1967Proxy(
            address(blacklistValidator),
            abi.encodeWithSelector(BlacklistValidatorUpgradeable.initialize.selector)
        );

        ControllerToken implementation = new ControllerToken();

        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeWithSelector(
                ControllerToken.initialize.selector,
                "Monerium EUR emoney",
                "EURe",
                bytes3("EUR"),
                address(validatorProxy)
            )
        );

        console.log("Deployed", "EURe", "at", address(proxy));
        vm.stopBroadcast();
    }

}

contract EUR is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        BlacklistValidatorUpgradeable blacklistValidator = new BlacklistValidatorUpgradeable();
        ERC1967Proxy validatorProxy = new ERC1967Proxy(
            address(blacklistValidator),
            abi.encodeWithSelector(BlacklistValidatorUpgradeable.initialize.selector)
        );

        Token implementation = new Token();

        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeWithSelector(
                implementation.initialize.selector,
                "Monerium EUR emoney",
                "EURe",
                address(validatorProxy)
            )
        );

        console.log("Deployed", "EURe", "at", address(proxy));
        vm.stopBroadcast();
    }

}

contract GBP is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        BlacklistValidatorUpgradeable blacklistValidator = new BlacklistValidatorUpgradeable();
        ERC1967Proxy validatorProxy = new ERC1967Proxy(
            address(blacklistValidator),
            abi.encodeWithSelector(BlacklistValidatorUpgradeable.initialize.selector)
        );

        Token implementation = new Token();

        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeWithSelector(
                implementation.initialize.selector,
                "Monerium GBP emoney",
                "GBPe",
                address(validatorProxy)
            )
        );

        console.log("Deployed", "GBPe", "at", address(proxy));
        vm.stopBroadcast();
    }

}
contract USD is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        BlacklistValidatorUpgradeable blacklistValidator = new BlacklistValidatorUpgradeable();
        ERC1967Proxy validatorProxy = new ERC1967Proxy(
            address(blacklistValidator),
            abi.encodeWithSelector(BlacklistValidatorUpgradeable.initialize.selector)
        );

        Token implementation = new Token();

        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeWithSelector(
                implementation.initialize.selector,
                "Monerium USD emoney",
                "USDe",
                address(validatorProxy)
            )
        );

        console.log("Deployed", "USDe", "at", address(proxy));
        vm.stopBroadcast();
    }

}
contract ISK is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        BlacklistValidatorUpgradeable blacklistValidator = new BlacklistValidatorUpgradeable();
        ERC1967Proxy validatorProxy = new ERC1967Proxy(
            address(blacklistValidator),
            abi.encodeWithSelector(BlacklistValidatorUpgradeable.initialize.selector)
        );

        Token implementation = new Token();

        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeWithSelector(
                implementation.initialize.selector,
                "Monerium ISK emoney",
                "ISKe",
                address(validatorProxy)
            )
        );

        console.log("Deployed", "ISKe", "at", address(proxy));
        vm.stopBroadcast();
    }

}

