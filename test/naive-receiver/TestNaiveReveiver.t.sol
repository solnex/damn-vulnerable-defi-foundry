//SPDX-License-Identifier:MIT

pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {Attacker} from "../../src/naive-receiver/Attacker.sol";
import {FlashLoanReceiver} from "../../src/naive-receiver/FlashLoanReceiver.sol";
import {NaiveReceiverLenderPool} from "../../src/naive-receiver/NaiveReceiverLenderPool.sol";

contract TestNaiveReveiver is Test {
    NaiveReceiverLenderPool pool;
    FlashLoanReceiver receiver;

    function setUp() public {
        //deploy pool and receiver
        pool = new NaiveReceiverLenderPool();
        receiver = new FlashLoanReceiver(address(pool));
        //transfer 1000 tokens to receiver
        vm.deal(address(pool), 1000 ether);
        vm.deal(address(receiver), 10 ether);

        assertEq(address(pool).balance, 1000 ether);

        assertEq(address(receiver).balance, 10 ether);
    }

    //every can call flashloan
    function test_AttackForEther() public {
        Attacker attackerContract = new Attacker(receiver, pool);
        address attacker = makeAddr("attacker");
        hoax(attacker, 1 ether);

        attackerContract.attack();

        assertEq(address(receiver).balance, 0 ether);
        assertEq(address(pool).balance, 1010 ether);
    }
}
