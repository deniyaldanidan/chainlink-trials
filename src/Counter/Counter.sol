// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Developed this smart-contract to test-out Time-based Chainlink Automation. USE HARDHAT-CHAINLINK-PLUGIN

contract Counter {
    uint256 private count;

    constructor() {
        count = 0;
    }

    function setCount() public {
        count += 1;
    }

    function getCount() public view returns (uint256) {
        return count;
    }
}
