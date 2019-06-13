pragma solidity 0.4.24;

import "./TokenFrontend.sol";

contract USD is TokenFrontend {

    constructor() 
        public
        TokenFrontend("Smart USD", "USDS", "USD") 
    { }

}
