pragma solidity ^0.4.11;

import "./TokenFrontend.sol";

contract EUR is TokenFrontend {
    function EUR(address _controller) 
        TokenFrontend("Smart EUR", "EURS", "EUR", _controller) 
    { }
}
