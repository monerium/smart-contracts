pragma solidity ^0.4.11;

import "./TokenFrontend.sol";

contract USD is TokenFrontend {
    function USD(address _controller) 
        TokenFrontend("Smart USD", "USDS", "USD", _controller) 
    { }
}
