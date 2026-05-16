// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {
    AutomationCompatibleInterface
} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";

contract Donator is AutomationCompatibleInterface {
    address private owner;

    event Donator_UserDonated(
        address indexed donatorAddr,
        uint256 donatedAmount,
        uint256 totalBalance
    );

    event Donator_OwnerWithdrewDonations(uint256 withdrewAmount);

    constructor(address _ownerAddr) {
        owner = _ownerAddr;
    }

    modifier _onlyOwner() {
        require(msg.sender == owner, "Only Owner role is allowed");
        _;
    }

    function donate() external payable {
        require(
            msg.value >= 0.001 ether,
            "Minimum 0.001 ether (1000000000000000 wei) is required"
        );
        emit Donator_UserDonated(msg.sender, msg.value, address(this).balance);
    }

    receive() external payable {
        require(
            msg.value >= 0.001 ether,
            "Minimum 0.001 ether (1000000000000000 wei) is required"
        );
        emit Donator_UserDonated(msg.sender, msg.value, address(this).balance);
    }

    // Withdraw if address(this).balance >= 0.02 ether

    function checkUpkeep(
        bytes memory /*checkData*/
    )
        public
        view
        override
        returns (bool upkeepNeeded, bytes memory /*performData*/)
    {
        upkeepNeeded = address(this).balance >= 0.02 ether;
    }

    function performUpkeep(bytes calldata /*performData*/) external override {
        (bool upkeepNeeded, ) = checkUpkeep("");
        require(
            upkeepNeeded,
            "Upkeep is currently not needed, Balance hasn't reached minimum amount"
        );
        uint256 amountToWithdraw = address(this).balance;
        (bool success, ) = owner.call{value: amountToWithdraw}("");
        require(success, "Donator: fund transaction failed");
        emit Donator_OwnerWithdrewDonations(amountToWithdraw);
    }
}
