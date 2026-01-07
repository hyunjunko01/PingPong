// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {PingPong} from "../src/PingPong.sol";

import {Client} from "@ccip/contracts/src/v0.8/ccip/libraries/Client.sol";
import {CCIPLocalSimulatorFork, Register} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";

contract PingPongTest is Test {
    PingPong sepoliaPingPong;
    PingPong arbSepoliaPingPong;

    CCIPLocalSimulatorFork ccipLocalSimulatorFork;

    uint256 sepoliaFork;
    uint256 arbSepoliaFork;

    Register.NetworkDetails sepoliaNetworkDetails;
    Register.NetworkDetails arbSepoliaNetworkDetails;

    address public user = makeAddr("user");

    function setUp() public {
        sepoliaFork = vm.createSelectFork("sepolia");
        arbSepoliaFork = vm.createFork("arb-sepolia");

        ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();
        vm.makePersistent(address(ccipLocalSimulatorFork)); // Make the simulator persistent across all forks

        // Deploy PingPong on sepolia
        sepoliaNetworkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid);
        sepoliaPingPong = new PingPong(sepoliaNetworkDetails.routerAddress);

        // Deploy PingPong on arb-sepolia
        vm.selectFork(arbSepoliaFork);
        arbSepoliaNetworkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid);
        arbSepoliaPingPong = new PingPong(arbSepoliaNetworkDetails.routerAddress);
    }

    function testPingPong() public {
        // Fund the ETH that will be used for CCIP fees for contracts and user
        vm.selectFork(sepoliaFork);
        vm.deal(address(sepoliaPingPong), 50 ether);

        vm.selectFork(arbSepoliaFork);
        vm.deal(address(arbSepoliaPingPong), 50 ether);

        vm.selectFork(sepoliaFork);
        vm.startPrank(user);
        sepoliaPingPong.ping(arbSepoliaNetworkDetails.chainSelector, address(arbSepoliaPingPong));
        vm.stopPrank();

        // Simulate message passing from Sepolia to Arbitrum Sepolia
        // Because this is a local simulator, there is no oracle to send the messages back and forth.
        ccipLocalSimulatorFork.switchChainAndRouteMessage(arbSepoliaFork);

        assertEq(arbSepoliaPingPong.s_lastReceivedMessage(), "ping");
        console.log("Arbitrum received Ping!");

        // Now, the Arbitrum Sepolia PingPong should send back a "Pong" message to the Sepolia PingPong
        ccipLocalSimulatorFork.switchChainAndRouteMessage(sepoliaFork);

        assertEq(sepoliaPingPong.s_lastReceivedMessage(), "pong");
        console.log("Sepolia received Pong!");
    }

    function test_Unit_RevertWhenNoBalanceOnArb() public {
        vm.selectFork(arbSepoliaFork);
        vm.deal(address(arbSepoliaPingPong), 0 ether);

        // fake Any2EVMMessage from Sepolia
        Client.Any2EVMMessage memory mockMsg = Client.Any2EVMMessage({
            messageId: bytes32(0),
            sourceChainSelector: 16015286601757825753, // ccip chain selector for sepolia
            sender: abi.encode(address(this)),
            data: abi.encode("ping"),
            destTokenAmounts: new Client.EVMTokenAmount[](0)
        });

        // pretend to be the router
        vm.prank(arbSepoliaNetworkDetails.routerAddress);
        vm.expectRevert(PingPong.PingPong__NotEnoughBalance.selector);
        arbSepoliaPingPong.ccipReceive(mockMsg);
    }

    function test_Unit_RevertWhenUnexpectedMessage() public {
        vm.selectFork(arbSepoliaFork);
        vm.deal(address(arbSepoliaPingPong), 10 ether);

        // fake Any2EVMMessage from Sepolia
        Client.Any2EVMMessage memory mockMsg = Client.Any2EVMMessage({
            messageId: bytes32(0),
            sourceChainSelector: 16015286601757825753, // ccip chain selector for sepolia
            sender: abi.encode(address(this)),
            data: abi.encode("hello"), // unexpected message
            destTokenAmounts: new Client.EVMTokenAmount[](0)
        });

        // pretend to be the router
        vm.prank(arbSepoliaNetworkDetails.routerAddress);
        vm.expectRevert(PingPong.PingPong__UnexpectedMessage.selector);
        arbSepoliaPingPong.ccipReceive(mockMsg);
    }
}
