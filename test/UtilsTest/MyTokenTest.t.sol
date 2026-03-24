// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {MyToken} from "../../src/utils/MyToken.sol";
import {Test} from "forge-std/Test.sol";

contract MyTokenTest is Test {
    MyToken myToken;
    address owner = makeAddr("owner");
    address minter = makeAddr("minter");
    address otherUser = makeAddr("other-user");

    function setUp() external {
        myToken = new MyToken(minter, owner);
    }

    function testCanMinterMint() external {
        uint256 initialBalance = myToken.balanceOf(minter);
        uint256 tokensToMint = 100;
        vm.prank(minter);
        myToken.mint(minter, tokensToMint);

        uint256 finalBalance = myToken.balanceOf(minter);

        assertEq(initialBalance + tokensToMint, finalBalance);
    }

    function testCanOthersMint() external {
        vm.startPrank(otherUser);
        vm.expectRevert("MyToken: Only minter allowed");
        myToken.mint(otherUser, 100);
        vm.stopPrank();
    }

    function testCanChangeMinter() external {
        address newMinter = makeAddr("new-minter");
        vm.prank(owner);
        myToken.changeMinter(newMinter);

        vm.assertEq(newMinter, myToken.getMinter());
    }

    function testCanOtherChangeMinter() external {
        address newMinter = makeAddr("new-minter");
        vm.prank(newMinter);
        vm.expectRevert("MyToken: Only owner allowed");
        myToken.changeMinter(newMinter);
    }
}
