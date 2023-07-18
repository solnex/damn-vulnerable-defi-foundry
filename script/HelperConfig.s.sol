//SPDX-License-Identifier:MIT

pragma solidity ^0.8.16;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;
    uint256 public constant DEFUALT_PRIVATEKEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    address public constant DEFUALT_ADDRESS =
        0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    struct NetworkConfig {
        uint256 deployerKey;
        address deployerAddress;
    }

    constructor() {
        if (block.chainid == 111555111) {
            activeNetworkConfig = getSepoliaNetworkConfig();
        } else {
            activeNetworkConfig = getAnvilNetworkConfig();
        }
    }

    function getAnvilNetworkConfig()
        internal
        pure
        returns (NetworkConfig memory)
    {
        return NetworkConfig(DEFUALT_PRIVATEKEY, DEFUALT_ADDRESS);
    }

    function getSepoliaNetworkConfig()
        internal
        pure
        returns (NetworkConfig memory)
    {
        return NetworkConfig(DEFUALT_PRIVATEKEY, DEFUALT_ADDRESS);
    }
}
