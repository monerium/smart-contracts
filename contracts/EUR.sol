pragma solidity ^0.4.10;

import "./TokenFrontend.sol";

contract EUR is TokenFrontend {
    function EUR(address _controller) 
        TokenFrontend("Smart EUR", "EURS", "EUR", _controller) 
    { }
}
