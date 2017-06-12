pragma solidity ^0.4.10;

import "./TokenController.sol";
import "./SmartToken.sol";
import "./BlacklistValidator.sol";

contract USD is TokenController {

    function USD() TokenController(new BlacklistValidator(), "Smart USD", "USDS") { }
}
