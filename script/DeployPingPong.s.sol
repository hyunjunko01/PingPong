// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {PingPong} from "../src/PingPong.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployPingPong is Script {
    function run() external returns (PingPong, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (address router,, uint256 deployerKey) = helperConfig.activeNetworkConfig();

        vm.startBroadcast(deployerKey);
        PingPong pingPong = new PingPong(router);
        vm.stopBroadcast();

        return (pingPong, helperConfig);
    }
}
