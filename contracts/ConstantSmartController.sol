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

import "./ConstantValidator.sol";
import "./SmartController.sol";

/**
 * @title ConstantSmartController
 * @dev Constantly rejects token transfers by using a rejecting validator.
 */
contract ConstantSmartController is SmartController {

    /**
     * @dev Contract constructor.
     * @param storage_ Address of the new storage.
     * @param ticker 3 letter currency ticker.
     */
    constructor(address storage_, bytes3 ticker)
        /* public */
      SmartController(storage_, address(new ConstantValidator(false)), ticker, address(0x0))
    { }

}
