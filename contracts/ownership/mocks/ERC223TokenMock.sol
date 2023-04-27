// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../../token/ERC20/BasicToken.sol";


interface ERC223ContractInterface {
  function tokenFallback(address _from, uint256 _value, bytes memory _data) external;
}


contract ERC223TokenMock is BasicToken {

  constructor(address initialAccount, uint256 initialBalance){
    balances[initialAccount] = initialBalance;
    totalSupply_ = initialBalance;
  }

  // ERC223 compatible transfer function (except the name)
  function transferERC223(address _to, uint256 _value, bytes memory _data) public
    returns (bool success)
  {
    transfer(_to, _value);
    bool isContract = false;
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      isContract := not(iszero(extcodesize(_to)))
    }
    if (isContract) {
      ERC223ContractInterface receiver = ERC223ContractInterface(_to);
      receiver.tokenFallback(msg.sender, _value, _data);
    }
    return true;
  }
}
