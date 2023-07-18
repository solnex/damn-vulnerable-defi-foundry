//SPDX-License-Identifier:MIT

pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {Attacker} from "../../src/truster/Attacker.sol";
import {AttackerUpgrade} from "../../src/truster/AttackerUpgrade.sol";
import {TrusterLenderPool} from "../../src/truster/TrusterLenderPool.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";

/* *
 * @title More and more lending pools are offering flash loans. In this case, a new pool has launched that is offering flash loans of DVT tokens for free.
The pool holds 1 million DVT tokens. You have nothing.
To pass this challenge, take all tokens out of the pool. If possible, in a single transaction.
 * */
contract TestTruster is Test {
    DamnValuableToken private token;
    TrusterLenderPool private pool;
    Attacker private attacker;
    AttackerUpgrade private attackerUpgrade;

    function setUp() public {
        //deploy TrusterLenderPool
        token = new DamnValuableToken();
        pool = new TrusterLenderPool(token);

        token.transfer(address(pool), 1000000 ether);
    }

    /**
     * we can struct the data and target to approve the money to attacker and then use transferFrom to steal the money
     */
    function test_stealMoneyFromPool() public {
        // deploy Attacker
        attacker = new Attacker(pool, token);

        //attacker attack
        address attackerAddr = makeAddr("attacker");
        hoax(attackerAddr, 1 ether); //gas
        attacker.attack();

        //assert
        assertEq(token.balanceOf(address(attackerAddr)), 1000000 ether);
    }

    function test_stealMoneyFromPoolWithinOneTx() public {
        // deploy Attacker
        address attackerAddr = makeAddr("attacker");
        hoax(attackerAddr, 1 ether); //gas

        attackerUpgrade = new AttackerUpgrade(pool, token);

        //assert
        assertEq(token.balanceOf(address(attackerAddr)), 1000000 ether);
    }
}
