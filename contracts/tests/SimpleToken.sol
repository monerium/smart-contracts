/* SPDX-License-Identifier: apache-2.0 */
/**
 * Copyright 2022 Monerium ehf.
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

import "../token/ERC20/BasicToken.sol";

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
