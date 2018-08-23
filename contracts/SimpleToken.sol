pragma solidity ^0.4.24;

import "zeppelin-solidity/contracts/token/ERC20/BasicToken.sol";

contract SimpleToken is BasicToken {

    constructor() public {
        totalSupply_ = 10000000;
        balances[msg.sender] = totalSupply_;
    }

}