/* SPDX-License-Identifier: apache-2.0 */
/**
 * Copyright 2019 Monerium ehf.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

pragma solidity 0.8.11;

//import "openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol";


abstract contract ERC20Basic {
  function totalSupply() public view virtual returns (uint256);
  function balanceOf(address _who) public view virtual returns (uint256);
  function transfer(address _to, uint256 _value) public virtual returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view override returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public override returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view override returns (uint256) {
    return balances[_owner];
  }
}

/**
 * @title SimpleToken
 * @dev This simple [ERC20] compatible token is used in the test suite.
 */
contract SimpleToken is BasicToken {

    constructor() {
        totalSupply_ = 10000000;
        balances[msg.sender] = totalSupply_;
    }

}
