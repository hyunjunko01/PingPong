// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address router;
        uint64 chainSelector;
        uint256 deployerKey;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        uint256 chainId = block.chainid;

        if (chainId == 11155111) {
            activeNetworkConfig = getSepoliaConfig();
        } else if (chainId == 421614) {
            activeNetworkConfig = getArbSepoliaConfig();
        } else {
            revert("Unsupported network");
        }
    }

    function getSepoliaConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            router: 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59,
            chainSelector: 16015286601757825753,
            deployerKey: vm.envUint("SEPOLIA_PRIVATE_KEY")
        });
    }

    function getArbSepoliaConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            router: 0x2a9C5afB0d0e4BAb2BCdaE109EC4b0c4Be15a165,
            chainSelector: 3478487238524512106,
            deployerKey: vm.envUint("ARB_SEPOLIA_PRIVATE_KEY")
        });
    }
}
