//SPDX-License-Identifier:MIT

pragma solidity ^0.8.16;
import {Test} from "forge-std/Test.sol";
import {DeployReceiverUnstoppable} from "../../script/DeployReceiverUnstoppable.s.sol";
import {ReceiverUnstoppable} from "../../src/unstoppable/ReceiverUnstoppable.sol";
import {UnstoppableVault} from "../../src/unstoppable/UnstoppableVault.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract TestReceiverUnstoppable is Test {
    UnstoppableVault public vault;
    ReceiverUnstoppable public receiver;
    DamnValuableToken public token;
    address public constant DEFAULT_ADDRESS =
        0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    HelperConfig public helperConfig;
    uint256 constant TOKENS_IN_VAULT = 1 ether;

    uint256 constant INITIAL_PLAYER_TOKEN_BALANCE = 0.1 ether;

    address public player = makeAddr("player");

    function setUp() public {
        DeployReceiverUnstoppable deploy = new DeployReceiverUnstoppable();
        (vault, receiver, token, helperConfig) = deploy.run();
        (, address deployerAddress) = helperConfig.activeNetworkConfig();
        assertEq(address(vault.asset()), address(token));
        vm.startPrank(DEFAULT_ADDRESS);
        token.approve(address(vault), TOKENS_IN_VAULT);
        vault.deposit(TOKENS_IN_VAULT, DEFAULT_ADDRESS);
        vm.stopPrank();

        assertEq(token.balanceOf(address(vault)), TOKENS_IN_VAULT);
        assertEq(vault.totalAssets(), TOKENS_IN_VAULT);
        assertEq(vault.totalSupply(), TOKENS_IN_VAULT);
        assertEq(vault.maxFlashLoan(address(token)), TOKENS_IN_VAULT);
        assertEq(vault.flashFee(address(token), TOKENS_IN_VAULT - 1), 0);
        assertEq(vault.flashFee(address(token), TOKENS_IN_VAULT), 0.05 ether);

        vm.prank(deployerAddress);
        token.transfer(player, INITIAL_PLAYER_TOKEN_BALANCE);
        assertEq(token.balanceOf(player), INITIAL_PLAYER_TOKEN_BALANCE);
    }

    function test_RevertWhenTransferTokenToVault() public {
        //arrange
        hoax(player, 100 ether);
        token.transfer(address(vault), 0.1 ether);
        //deploy a receiver contract for player
        ReceiverUnstoppable receiverForPlayer = new ReceiverUnstoppable(
            address(vault)
        );
        //act & assert
        vm.expectRevert(UnstoppableVault.InvalidBalance.selector);
        receiverForPlayer.executeFlashLoan(1 ether);
    }
}
