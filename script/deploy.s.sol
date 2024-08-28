// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Token.sol";
import "../src/ControllerToken.sol";
import "../src/GnosisControllerToken.sol";
import "../src/PolygonControllerToken.sol";
import "../src/EthereumControllerToken.sol";

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
        console.log("Deployed BlacklistValidatorUpgradeable at ", address(validatorProxy));
        // Deploy only one implementation of the Token contract for all currencies.
        Token implementation = new Token();

        deployTokenProxy(implementation, "Monerium EURe", "EURe", address(validatorProxy));
        deployTokenProxy(implementation, "Monerium GBPe", "GBPe", address(validatorProxy));
        deployTokenProxy(implementation, "Monerium ISKe", "ISKe", address(validatorProxy));
        deployTokenProxy(implementation, "Monerium USDe", "USDe", address(validatorProxy));

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

contract BlacklistValidator is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        BlacklistValidatorUpgradeable blacklistValidator = new BlacklistValidatorUpgradeable();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(blacklistValidator),
            abi.encodeWithSelector(BlacklistValidatorUpgradeable.initialize.selector)
        );

        console.log("Deployed", "Validator", "at", address(proxy));
        vm.stopBroadcast();
    }
}

contract AllControllerGnosis is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        BlacklistValidatorUpgradeable blacklistValidator = new BlacklistValidatorUpgradeable();
        ERC1967Proxy validatorProxy = new ERC1967Proxy(
            address(blacklistValidator),
            abi.encodeWithSelector(BlacklistValidatorUpgradeable.initialize.selector)
        );

        // Deploy only one implementation of the Token contract for all currencies.
        GnosisControllerToken implementation = new GnosisControllerToken();

        console.log("Deployed BlacklistValidatorUpgradeable at ", address(validatorProxy));
        deployTokenProxy(implementation, "Monerium EURe", "EURe", bytes3("EUR"), address(validatorProxy));
        deployTokenProxy(implementation, "Monerium GBPe", "GBPe", bytes3("GBP"), address(validatorProxy));
        deployTokenProxy(implementation, "Monerium ISKe", "ISKe", bytes3("ISK") ,address(validatorProxy));
        deployTokenProxy(implementation, "Monerium USDe", "USDe", bytes3("USD") ,address(validatorProxy));

        vm.stopBroadcast();
    }

    function deployTokenProxy(
        GnosisControllerToken implementation,
        string memory name,
        string memory symbol,
        bytes3 _ticker,
        address validatorProxy
    ) internal {
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeWithSelector(
                GnosisControllerToken.initialize.selector,
                name,
                symbol,
                _ticker,
                validatorProxy
            )
        );

        console.log("Deployed", symbol, "at", address(proxy));
    }
}


contract AllControllerPolygon is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        BlacklistValidatorUpgradeable blacklistValidator = new BlacklistValidatorUpgradeable();
        ERC1967Proxy validatorProxy = new ERC1967Proxy(
            address(blacklistValidator),
            abi.encodeWithSelector(BlacklistValidatorUpgradeable.initialize.selector)
        );

        // Deploy only one implementation of the Token contract for all currencies.
        PolygonControllerToken implementation = new PolygonControllerToken();

        console.log("Deployed BlacklistValidatorUpgradeable at ", address(validatorProxy));
        deployTokenProxy(implementation, "Monerium EURe", "EURe", bytes3("EUR"), address(validatorProxy));
        deployTokenProxy(implementation, "Monerium GBPe", "GBPe", bytes3("GBP"), address(validatorProxy));
        deployTokenProxy(implementation, "Monerium ISKe", "ISKe", bytes3("ISK") ,address(validatorProxy));
        deployTokenProxy(implementation, "Monerium USDe", "USDe", bytes3("USD") ,address(validatorProxy));

        vm.stopBroadcast();
    }

    function deployTokenProxy(
        PolygonControllerToken implementation,
        string memory name,
        string memory symbol,
        bytes3 _ticker,
        address validatorProxy
    ) internal {
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeWithSelector(
                PolygonControllerToken.initialize.selector,
                name,
                symbol,
                _ticker,
                validatorProxy
            )
        );

        console.log("Deployed", symbol, "at", address(proxy));
    }
}

contract AllControllerEthereum is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        BlacklistValidatorUpgradeable blacklistValidator = new BlacklistValidatorUpgradeable();
        ERC1967Proxy validatorProxy = new ERC1967Proxy(
            address(blacklistValidator),
            abi.encodeWithSelector(BlacklistValidatorUpgradeable.initialize.selector)
        );

        // Deploy only one implementation of the Token contract for all currencies.
        EthereumControllerToken implementation = new EthereumControllerToken();

        console.log("Deployed BlacklistValidatorUpgradeable at ", address(validatorProxy));
        deployTokenProxy(implementation, "Monerium EURe", "EURe", bytes3("EUR"), address(validatorProxy));
        deployTokenProxy(implementation, "Monerium GBPe", "GBPe", bytes3("GBP"), address(validatorProxy));
        deployTokenProxy(implementation, "Monerium ISKe", "ISKe", bytes3("ISK") ,address(validatorProxy));
        deployTokenProxy(implementation, "Monerium USDe", "USDe", bytes3("USD") ,address(validatorProxy));

        vm.stopBroadcast();
    }

    function deployTokenProxy(
        EthereumControllerToken implementation,
        string memory name,
        string memory symbol,
        bytes3 _ticker,
        address validatorProxy
    ) internal {
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeWithSelector(
                EthereumControllerToken.initialize.selector,
                name,
                symbol,
                _ticker,
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

