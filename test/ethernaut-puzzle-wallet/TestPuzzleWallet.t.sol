//SPDX-License-Identifier:MIT

pragma solidity ^0.8.16;
import {Test, console} from "forge-std/Test.sol";
import {PuzzleWallet, PuzzleProxy} from "../../src/ethernaut-puzzle-wallet/PuzzleWallet.sol";
import {Attacker} from "../../src/ethernaut-puzzle-wallet/Attacker.sol";
contract TestPuzzleWallet is Test {
    PuzzleWallet puzzleWallet;
    PuzzleProxy proxy;
    address owner = makeAddr("owner");

    function setUp() public {
        puzzleWallet = new PuzzleWallet();
        uint256 maxBalance = 1 ether;
        bytes memory initData = abi.encodeWithSignature(
            "init(uint256)",
            maxBalance
        );
        address admin = makeAddr("admin"); //control contract update
        vm.deal(admin, 1 ether);
        //control contract parameter
        hoax(owner, 1 ether);
        proxy = new PuzzleProxy(admin, address(puzzleWallet), initData);

        (, bytes memory data) = address(proxy).call(
            abi.encodeWithSignature("owner()")
        );
        address ownerReal = abi.decode(data, (address));
        assertEq(owner, ownerReal);
        assertEq(proxy.admin(), admin);
    }

    function test_init() public {
        address hacker = makeAddr("hacker");
        hoax(hacker, 1 ether);
        new Attacker(payable(address(proxy)));
        assertEq(proxy.admin(), hacker);
    }
}
