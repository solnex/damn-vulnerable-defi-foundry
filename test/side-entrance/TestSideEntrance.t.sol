//SPDX-license-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {Attacker} from "../../src/side-entrance/Attacker.sol";
import {SideEntranceLenderPool} from "../../src/side-entrance/SideEntranceLenderPool.sol";

contract TestSideEntrance is Test {
    SideEntranceLenderPool pool;
    uint256 public constant ETHER_INATAIL_In_POOL = 1000 ether;
    uint256 public constant ETHER_INATAIL_In_ATTACKER = 1 ether;

    function setUp() public {
        //deploy SideEntranceLenderPool

        pool = new SideEntranceLenderPool();
        //transfer 1000 tokens to pool
        vm.deal(address(pool), ETHER_INATAIL_In_POOL);
    }

    function test_UseReentrancyToDrainPool() public {
        //arrange
        address attacker = makeAddr("attacker");
        hoax(attacker, ETHER_INATAIL_In_ATTACKER);
        Attacker attackerContract = new Attacker(pool);

        vm.prank(attacker);
        attackerContract.attack();

        //assert
        assertEq(address(pool).balance, 0);
        assertEq(
            attacker.balance,
            ETHER_INATAIL_In_ATTACKER + ETHER_INATAIL_In_POOL
        );
    }
}
