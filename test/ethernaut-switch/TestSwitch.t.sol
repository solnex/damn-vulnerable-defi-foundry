//SPDX-License-Identifier:MIT

pragma solidity ^0.8.16;
import {Test} from "forge-std/Test.sol";
import {Attacker} from "../../src/ethernaut-switch/Attacker.sol";
import {Switch} from "../../src/ethernaut-switch/Switch.sol";

contract TestSwitch is Test {
    Switch _s;

    function setUp() public {
        _s = new Switch();
    }

    function test_SwitchIsOn() public {
        Attacker attackerContract = new Attacker(address(_s));
        address attacker = makeAddr("attacker");
        hoax(attacker, 1 ether);

        assertEq(_s.switchOn(), false);
        attackerContract.attack();
        assertEq(_s.switchOn(), true);
    }
}
