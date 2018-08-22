pragma solidity ^0.4.24;

import "./TokenFrontend.sol";

contract EUR is TokenFrontend {

    constructor(address controller) 
        public
        TokenFrontend("Smart EUR", "EURS", "EUR", controller) 
    { }

}
