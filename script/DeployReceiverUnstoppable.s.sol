//SPDX-License-Identifier:MIT

pragma solidity ^0.8.16;

import {Script} from "forge-std/Script.sol";
import {ReceiverUnstoppable} from "../src/unstoppable/ReceiverUnstoppable.sol";
import {UnstoppableVault} from "../src/unstoppable/UnstoppableVault.sol";
import {DamnValuableToken} from "../src/DamnValuableToken.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployReceiverUnstoppable is Script {
    UnstoppableVault public pool;
    ReceiverUnstoppable public receiver;
    DamnValuableToken public token;

    function run()
        public
        returns (
            UnstoppableVault,
            ReceiverUnstoppable,
            DamnValuableToken,
            HelperConfig
        )
    {
        HelperConfig helperConfig = new HelperConfig();
        (uint256 deployerKey, address deployerAccount) = helperConfig
            .activeNetworkConfig();
        vm.startBroadcast(deployerKey);
        token = new DamnValuableToken();
        pool = new UnstoppableVault(token, deployerAccount, deployerAccount);
        receiver = new ReceiverUnstoppable(address(pool));
        vm.stopBroadcast();
        return (pool, receiver, token, helperConfig);
    }
}
