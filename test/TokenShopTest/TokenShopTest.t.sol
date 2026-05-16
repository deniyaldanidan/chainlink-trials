// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {TokenShop} from "../../src/TokenShop/TokenShop.sol";
import {MyToken} from "../../src/utils/MyToken.sol";

contract TokenShopTest is Test {
    MyToken myToken;
    TokenShop tokenShop;

    address constant SEPOLIA_DATA_FEED_ADDRESS =
        0x694AA1769357215DE4FAC081bf1f309aDC325306;

    address owner = makeAddr("owner");
    address user = makeAddr("user");

    function setUp() external {
        myToken = new MyToken(owner, owner);
        tokenShop = new TokenShop(address(myToken), SEPOLIA_DATA_FEED_ADDRESS);

        vm.prank(owner);
        myToken.changeMinter(address(tokenShop));
        require(
            address(tokenShop) == myToken.getMinter(),
            "Minter change not succeeded"
        );
        vm.deal(user, 1 ether);
    }

    function testDoesPriceFeedWorks() external view {
        uint256 priceOf1Eth = tokenShop.getAmountOfTokensToMintFor1Eth();
        console2.log(priceOf1Eth);
    }

    function testGetAmountOfTokenToMintForGivenEth() external view {
        console2.log(tokenShop.getAmountOfTokensToMintForGivenEth(0.01 ether));
    }

    function testBuyTokens() external {
        uint256 amountOfEthToPay = 0.01 ether;
        uint256 mintableTokens = tokenShop.getAmountOfTokensToMintForGivenEth(
            amountOfEthToPay
        );
        uint256 userInitialBalance = myToken.balanceOf(user);

        vm.prank(user);
        tokenShop.buyTokens{value: amountOfEthToPay}(mintableTokens, user);

        uint256 userFinalBalance = myToken.balanceOf(user);

        console2.log(mintableTokens, userInitialBalance + userFinalBalance);

        assertEq(userInitialBalance + userFinalBalance, mintableTokens);
    }
}
