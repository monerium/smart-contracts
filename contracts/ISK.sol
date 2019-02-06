pragma solidity 0.4.24;

import "./TokenFrontend.sol";

contract ISK is TokenFrontend {

    constructor(address controller) 
        public
        TokenFrontend("Smart ISK", "ISKS", "ISK", controller) 
    { }

}
