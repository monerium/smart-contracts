pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol";

/**
 * @title SimpleToken
 * @dev This simple [ERC20] compatible token is used in the test suite.
 */
contract SimpleToken is BasicToken {

    constructor() public {
        totalSupply_ = 10000000;
        balances[msg.sender] = totalSupply_;
    }

}
