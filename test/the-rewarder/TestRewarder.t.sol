//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import {Test, console} from "forge-std/Test.sol";
import {AccountingToken} from "../../src/the-rewarder/AccountingToken.sol";
import {FlashLoanerPool} from "../../src/the-rewarder/FlashLoanerPool.sol";
import {RewardToken} from "../../src/the-rewarder/RewardToken.sol";
import {TheRewarderPool} from "../../src/the-rewarder/TheRewarderPool.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";
import {Solution} from "../../src/the-rewarder/Solution.sol";

contract TestReward is Test {
    AccountingToken public accountingToken;
    FlashLoanerPool public flashLoanerPool;
    RewardToken public rewardToken;
    TheRewarderPool public theRewarderPool;
    DamnValuableToken public liquidityToken;
    address public depolyer = makeAddr("depolyer");
    uint256 public constant TOKENS_IN_LENDER_POOL = 1000000 ether;
    uint256 public constant USERCOUNT = 5;
    address public player = makeAddr("player");

    function setUp() public {
        vm.startPrank(depolyer);

        liquidityToken = new DamnValuableToken();
        flashLoanerPool = new FlashLoanerPool(address(liquidityToken));
        theRewarderPool = new TheRewarderPool(address(liquidityToken));
        accountingToken = theRewarderPool.accountingToken();
        rewardToken = theRewarderPool.rewardToken();
        // Set initial token balance of the pool offering flash loans
        liquidityToken.transfer(
            address(flashLoanerPool),
            TOKENS_IN_LENDER_POOL
        );

        uint256 depositAmount = 100 ether;

        for (uint256 i = 0; i < USERCOUNT; i++) {
            address user = address(uint160(i + 1));
            vm.prank(depolyer);
            liquidityToken.transfer(user, depositAmount);
            vm.startPrank(user);
            liquidityToken.approve(address(theRewarderPool), depositAmount);
            theRewarderPool.deposit(depositAmount);
            vm.stopPrank();
            assertEq(accountingToken.balanceOf(user), depositAmount);
        }
        assertEq(accountingToken.totalSupply(), USERCOUNT * depositAmount);
        // Advance time 5 days so that depositors can get rewards
        vm.warp(block.timestamp + 5 days);

        // Each depositor gets reward tokens
        uint256 rewardsInRound = theRewarderPool.REWARDS();
        for (uint256 i = 0; i < USERCOUNT; i++) {
            address user = address(uint160(i + 1));
            vm.prank(user);
            theRewarderPool.distributeRewards();
            assertEq(rewardToken.balanceOf(user), rewardsInRound / USERCOUNT);
        }
        assertEq(rewardToken.totalSupply(), rewardsInRound);
        assertEq(theRewarderPool.roundNumber(), 2);
    }

    function test_reward() public {
         
        excute();

        assertEq(theRewarderPool.roundNumber(), 3);
        // Users should get neglegible rewards this round
        for (uint256 i = 0; i < 5; i++) {
            address user = address(uint160(i + 1));
            vm.prank(user);
            theRewarderPool.distributeRewards();

            uint256 userRewards = rewardToken.balanceOf(user);
            console.log("userRewards", userRewards);
            uint256 delta = userRewards - theRewarderPool.REWARDS() / USERCOUNT;
            assertLt(delta, 0.01 ether);
        }

        // Rewards must have been issued to the player account
        assertGt(rewardToken.totalSupply(), theRewarderPool.REWARDS());
        uint256 playerRewards = rewardToken.balanceOf(player);
        assertGt(playerRewards, 0);
    }

    /** you should do something in this function to get the most of reward token **/
    function excute() private {
        //flashloan
        //first one in a new round to deposit will also get the reward token in last round
        //reward pool has bug
        uint256 lastRecordedSnapshotTimestamp = theRewarderPool
            .lastRecordedSnapshotTimestamp();
        vm.warp(lastRecordedSnapshotTimestamp + 5 days);
        vm.startPrank(player);
        Solution solution = new Solution(
            address(flashLoanerPool),
            address(theRewarderPool)
        );
        solution.excute();
    }
}
