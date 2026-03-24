// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {MyToken} from "../utils/MyToken.sol";
import {
    AggregatorV3Interface
} from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract TokenShop {
    MyToken private immutable I_MYTOKEN;
    AggregatorV3Interface private ethUsdDataFeed;

    constructor(address _myTokenAddress, address _dataFeedAddr) {
        I_MYTOKEN = MyToken(_myTokenAddress);
        ethUsdDataFeed = AggregatorV3Interface(_dataFeedAddr); // price-feed address of ETH/USD
    }

    function getPriceOf1ETHinUSD() public view returns (uint256) {
        (, int256 answer, , , ) = ethUsdDataFeed.latestRoundData();
        return uint256(answer);
    }
}

/**
 *! INCOMPLETE: WILL DO THIS LATER
 */
