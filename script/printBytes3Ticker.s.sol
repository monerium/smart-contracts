// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

contract PrintBytes3TickerScript is Script {
    function run() view external {
        console.log("EUR");
        console.logBytes3(bytes3("EUR"));
        console.log("GBP");
        console.logBytes3(bytes3("GBP"));
        console.log("USD");
        console.logBytes3(bytes3("USD"));
        console.log("ISK");
        console.logBytes3(bytes3("ISK"));
    }
}
