pragma solidity ^0.4.24;

import "./TokenFrontend.sol";

contract USD is TokenFrontend {
    function USD(address _controller) 
        public
        TokenFrontend("Smart USD", "USDS", "USD", _controller) 
    { }
}
