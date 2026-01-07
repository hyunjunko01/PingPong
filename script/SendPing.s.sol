// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {PingPong} from "../src/PingPong.sol";

contract SendPing is Script {
    function run() external {
        address sepoliaPingPongAddress = vm.envAddress("SEPOLIA_PINGPONG_ADDRESS");
        uint64 arbSepoliaChainSelector = 3478487238524512106;
        address arbSepoliaPingPongAddress = vm.envAddress("ARB_SEPOLIA_PINGPONG_ADDRESS");

        uint256 sepoliaPrivateKey = vm.envUint("SEPOLIA_PRIVATE_KEY");

        vm.startBroadcast(sepoliaPrivateKey);
        PingPong(payable(sepoliaPingPongAddress)).ping{value: 0.001 ether}(
            arbSepoliaChainSelector, arbSepoliaPingPongAddress
        );
        vm.stopBroadcast();

        console.log("Ping sent! Check CCIP Explorer with the transaction hash.");
    }
}
