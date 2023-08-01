//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import {Test, console} from "forge-std/Test.sol";
import {Attacker} from "../../src/selfie/Attacker.sol";
import {SelfiePool} from "../../src/selfie/SelfiePool.sol";
import {SimpleGovernance} from "../../src/selfie/SimpleGovernance.sol";
import {DamnValuableTokenSnapshot} from "../../src/DamnValuableTokenSnapshot.sol";

contract TestSelfie is Test {
    DamnValuableTokenSnapshot private token;
    SimpleGovernance private governance;
    SelfiePool private pool;

    uint256 public constant INITIAL_SUPPLY = 2000000 ether;
    uint256 public constant INITIAL_TOKENINPOOL = 1500000 ether;
    address public DEPLOYER = makeAddr("deployer");
    address public ATTACKER = makeAddr("attacker");

    function setUp() public {
        vm.startPrank(DEPLOYER);
        token = new DamnValuableTokenSnapshot(INITIAL_SUPPLY);
        governance = new SimpleGovernance(address(token));
        pool = new SelfiePool(address(token), address(governance));
        //Fund the pool
        token.transfer(address(pool), INITIAL_TOKENINPOOL);
        token.snapshot();
        vm.stopPrank();
        assertEq(token.balanceOf(address(pool)), INITIAL_TOKENINPOOL);
        assertEq(pool.maxFlashLoan(address(token)), INITIAL_TOKENINPOOL);
        assertEq(pool.flashFee(address(token), 0), 0);
    }

    function test_attack() public {
        vm.startPrank(ATTACKER);
        Attacker attacker = new Attacker(governance, pool, address(token));
        attacker.proposal();

        vm.warp(block.timestamp + 2 days);
        attacker.excute();
        assertEq(token.balanceOf(ATTACKER), INITIAL_TOKENINPOOL);
        assertEq(token.balanceOf(address(pool)), 0);
    }
}
