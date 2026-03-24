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

    function setUp() external {
        myToken = new MyToken(owner, owner);
        tokenShop = new TokenShop(address(myToken), SEPOLIA_DATA_FEED_ADDRESS);

        vm.prank(owner);
        myToken.changeMinter(address(tokenShop));
        require(
            address(tokenShop) == myToken.getMinter(),
            "Minter change not succeeded"
        );
    }

    function testDoesPriceFeedWorks() external view {
        uint256 priceOf1Eth = tokenShop.getPriceOf1ETHinUSD();
        console2.log(priceOf1Eth);
    }
}
