pragma solidity ^0.4.10;

import "./SmartToken.sol";

contract TokenController {
    address token;

    function TokenController(address _validator, string _name, string _symbol) {
        token = new SmartToken(_validator, _name, _symbol);
    }

    function getToken() returns (address) {
        return token;
    }

    function setToken(address _token) {
        token = _token;
    }

}
