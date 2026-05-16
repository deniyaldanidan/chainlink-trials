// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {MyToken} from "../utils/MyToken.sol";
import {
    AggregatorV3Interface
} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// - TokenShop will mint tokens (x amount of tokens == worth of Eth/USD) to users for the Eth they pay.

contract TokenShop {
    MyToken private immutable I_MYTOKEN;
    AggregatorV3Interface private ethUsdDataFeed;
    uint256 private constant MINIMUM_ETH_AMOUNT = 0.001 ether;
    uint256 private constant USD_DECIMALS = 1e8;
    uint256 private constant TOKEN_DECIMALS = 1e18;

    event TokenShop_TokensMinted(
        address indexed recipient,
        uint256 amountOfTokensMinted
    );

    constructor(address _myTokenAddress, address _dataFeedAddr) {
        I_MYTOKEN = MyToken(_myTokenAddress);
        ethUsdDataFeed = AggregatorV3Interface(_dataFeedAddr); // price-feed address of ETH/USD
    }

    function buyTokens(
        uint256 _minTokensToMint,
        address _recipientAddr
    ) external payable {
        // Min eth address Check
        require(
            msg.value >= MINIMUM_ETH_AMOUNT,
            "TokenShop: Minimum 0.001 eth (1000000000000000 wei) is required"
        );
        // Zero address check
        require(
            _recipientAddr != address(0),
            "TokenShop: Recipient Address Should not be Zero Address"
        );
        uint256 _amountOfTokensToMint = getAmountOfTokensToMintForGivenEth(
            msg.value
        );
        // Slippage check
        require(
            _amountOfTokensToMint >= _minTokensToMint,
            "TokenShop: Could'nt mint the required minimum amount"
        );
        // Mint tokens
        I_MYTOKEN.mint(_recipientAddr, _amountOfTokensToMint);
        emit TokenShop_TokensMinted(_recipientAddr, _amountOfTokensToMint);
    }

    function getAmountOfTokensToMintFor1Eth() public view returns (uint256) {
        (, int256 answer, , , ) = ethUsdDataFeed.latestRoundData();
        uint256 priceOf1Eth = (uint256(answer) * TOKEN_DECIMALS) / USD_DECIMALS;
        return priceOf1Eth;
        // return (priceOf1Eth * 1000000000000000) / 1e18;
    }

    function getAmountOfTokensToMintForGivenEth(
        uint256 _ethAmount
    ) public view returns (uint256) {
        return (getAmountOfTokensToMintFor1Eth() * _ethAmount) / TOKEN_DECIMALS;
    }

    function getMinimumEthAmount() external pure returns (uint256) {
        return MINIMUM_ETH_AMOUNT;
    }
}
