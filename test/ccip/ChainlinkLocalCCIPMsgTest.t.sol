// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {
    CCIPLocalSimulator,
    IRouterClient,
    LinkToken
} from "@chainlink/local/src/ccip/CCIPLocalSimulator.sol";
import {
    MessageSender
} from "../../src/CcipLesson/chainlink-local/MessageSender.sol";
import {
    MessageReceiver
} from "../../src/CcipLesson/chainlink-local/MessageReceiver.sol";

contract ChainlinkLocalCCIPMsgTest is Test {
    CCIPLocalSimulator private ccipLocalSimulator;
    uint64 chainSelector;
    MessageSender sender;
    MessageReceiver receiver;

    function setUp() external {
        ccipLocalSimulator = new CCIPLocalSimulator();

        (
            uint64 _chainSelector,
            IRouterClient sourceRouter,
            IRouterClient destinationRouter,
            ,
            LinkToken linkToken,
            ,

        ) = ccipLocalSimulator.configuration();

        chainSelector = _chainSelector;

        sender = new MessageSender(address(sourceRouter), address(linkToken));
        receiver = new MessageReceiver(address(destinationRouter));

        ccipLocalSimulator.requestLinkFromFaucet(address(sender), 10);
    }

    function testSendMessage() external {
        sender.sendMessage(chainSelector, address(receiver));

        (, string memory text) = receiver.getLastReceivedMessageDetails();
        console.log(text); // This will print "Hey There!" on the console
    }
}
