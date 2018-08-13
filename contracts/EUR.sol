pragma solidity ^0.4.24;

import "./TokenFrontend.sol";

contract EUR is TokenFrontend {
    constructor(address _controller) 
        public
        TokenFrontend("Smart EUR", "EURS", "EUR", _controller) 
    { }
}
