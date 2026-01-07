// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Register} from "@chainlink-local/src/ccip/Register.sol";
import {Client} from "@ccip/contracts/src/v0.8/ccip/libraries/Client.sol";
import {IRouterClient} from "@ccip/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {CCIPReceiver} from "@ccip/contracts/src/v0.8/ccip/applications/CCIPReceiver.sol";

/**
 * @title PingPong
 * @author Tyler Ko (Hyunjun Ko)
 * @notice A contract that sends "Ping" messages to a receiver on a different chain and expects "Pong" responses.
 */
contract PingPong is CCIPReceiver {
    error PingPong__UnexpectedMessage();
    error PingPong__NotEnoughBalance();

    string public s_lastReceivedMessage;

    event PingPongCompleted();

    constructor(address router) CCIPReceiver(router) {}

    /**
     * @notice Sends a "Ping" message to a receiver on a different chain.
     * @param destinationChainSelector The chain selector of the destination chain.
     * @param receiver The address of the receiver on the destination chain.
     */
    function ping(uint64 destinationChainSelector, address receiver) external payable {
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: abi.encode("ping"), // we cannot just send a string, we need to encode it first.
            tokenAmounts: new Client.EVMTokenAmount[](0), // Since this is a messaging project (no tokens), we should provide an empty array.
            feeToken: address(0),
            extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: 200_000}))
        });

        uint256 fee = IRouterClient(getRouter()).getFee(destinationChainSelector, message);

        IRouterClient(getRouter()).ccipSend{value: fee}(destinationChainSelector, message);
    }

    /**
     * @notice Send a "Pong" message back to the original sender upon receiving a "Ping".
     * @param message The received Any2EVMMessage from source chain.
     */
    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        address senderAddress = abi.decode(message.sender, (address)); // The message.sender is of type bytes, so we need to decode it.
        string memory receivedMessage = abi.decode(message.data, (string));

        // Using a state variable to store the last received message for verification in tests
        // If the transaction fails, the state change will be reverted
        s_lastReceivedMessage = receivedMessage;

        // In solidity, string comparison is done via hashing
        if (keccak256(abi.encodePacked(receivedMessage)) == keccak256(abi.encodePacked("ping"))) {
            Client.EVM2AnyMessage memory returnMessage = Client.EVM2AnyMessage({
                receiver: abi.encode(senderAddress),
                data: abi.encode("pong"), // we cannot just send a string, we need to encode it first.
                tokenAmounts: new Client.EVMTokenAmount[](0), // Since this is a messaging project (no tokens), we should provide an empty array.
                feeToken: address(0),
                extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: 200_000}))
            });

            uint256 fee = IRouterClient(getRouter()).getFee(message.sourceChainSelector, returnMessage);

            if (address(this).balance < fee) revert PingPong__NotEnoughBalance();

            IRouterClient(getRouter()).ccipSend{value: fee}(message.sourceChainSelector, returnMessage);
        } else if (keccak256(abi.encodePacked(receivedMessage)) == keccak256(abi.encodePacked("pong"))) {
            emit PingPongCompleted();
        } else {
            revert PingPong__UnexpectedMessage();
        }
    }

    /**
     * @notice Allows the contract to receive ETH to pay for CCIP fees.
     */
    receive() external payable {}
}
