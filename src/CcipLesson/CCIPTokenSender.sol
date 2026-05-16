// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {
    IRouterClient
} from "@chainlink/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts/src/v0.8/ccip/libraries/Client.sol";
import {
    SafeERC20
} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// IROUTERCLIENT => Interface for the CCIP router that handles cross-chain messaging
// Client => Library with Data structures for CCIP messages

contract CCIPTokenSender is Ownable {
    using SafeERC20 for IERC20;

    // Visit here for info's https://docs.chain.link/ccip/directory/testnet
    IRouterClient private immutable CCIP_ROUTER; // CCIP_ROUTER address for source-chain
    uint64 private immutable DESTINATION_CHAIN_SELECTOR; // CHAIN_SELECTOR for destination-chain

    IERC20 private immutable LINK_TOKEN; // Link-Fee Token address on source-chain
    IERC20 private immutable USDC_TOKEN; // Token address on source-Chain

    error CCIPTokenSender__InsufficientBalance(
        IERC20 erc20Token,
        uint256 _userBalance,
        uint256 _amount
    );
    error CCIPTokenSender__NothingToWithdraw();

    event USDCTransferred(
        bytes32 indexed messageId,
        uint64 indexed destinationChainSelector,
        address indexed receiver,
        uint256 amount,
        uint256 fee
    );

    constructor(
        address _routerClient,
        address _linkTokenAddr,
        address _usdcTokenAddr,
        uint64 _destinationChainSelector
    ) Ownable(msg.sender) {
        CCIP_ROUTER = IRouterClient(_routerClient);
        LINK_TOKEN = IERC20(_linkTokenAddr);
        USDC_TOKEN = IERC20(_usdcTokenAddr);
        DESTINATION_CHAIN_SELECTOR = _destinationChainSelector;
    }

    function transferTokens(
        address _receiver,
        uint256 _amount
    ) external returns (bytes32 messageId) {
        // * If user doesnt have sufficient-balance => revert..
        if (_amount > USDC_TOKEN.balanceOf(msg.sender)) {
            revert CCIPTokenSender__InsufficientBalance(
                USDC_TOKEN,
                USDC_TOKEN.balanceOf(msg.sender),
                _amount
            );
        }
        // * Prepare token-information to send it cross-chain
        Client.EVMTokenAmount[]
            memory _tokenAmounts = new Client.EVMTokenAmount[](1);
        Client.EVMTokenAmount memory _tokenAmount = Client.EVMTokenAmount({
            token: address(USDC_TOKEN), // token-address in source-chain
            amount: _amount
        });

        _tokenAmounts[0] = _tokenAmount;
        // * Build CCIP-Message
        Client.EVM2AnyMessage memory _message = Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver),
            data: "", // data is not needed for transfering tokens
            tokenAmounts: _tokenAmounts,
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({
                    gasLimit: 0 // Since we're only transfering tokens and Not executing any transactions upon receiving... gas is not needed
                })
            ),
            feeToken: address(LINK_TOKEN)
        });
        // * Handle Fee
        uint256 _ccipFee = CCIP_ROUTER.getFee(
            DESTINATION_CHAIN_SELECTOR,
            _message
        );
        if (_ccipFee > LINK_TOKEN.balanceOf(address(this))) {
            revert CCIPTokenSender__InsufficientBalance(
                LINK_TOKEN,
                LINK_TOKEN.balanceOf(address(this)),
                _ccipFee
            );
        }
        LINK_TOKEN.approve(address(CCIP_ROUTER), _ccipFee);

        // * Approve USDC-TOKEN amounts to ROUTER for transfer
        USDC_TOKEN.safeTransferFrom(msg.sender, address(this), _amount);
        USDC_TOKEN.approve(address(CCIP_ROUTER), _amount);

        // * Send the message to the Router
        messageId = CCIP_ROUTER.ccipSend(DESTINATION_CHAIN_SELECTOR, _message);

        emit USDCTransferred(
            messageId,
            DESTINATION_CHAIN_SELECTOR,
            _receiver,
            _amount,
            _ccipFee
        );
    }

    function withdrawToken(address _beneficiary) public onlyOwner {
        uint256 _amount = USDC_TOKEN.balanceOf(address(this));
        if (_amount == 0) {
            revert CCIPTokenSender__NothingToWithdraw();
        }
        USDC_TOKEN.safeTransfer(_beneficiary, _amount);
    }

    function withdrawFee(address _beneficiary) public onlyOwner {
        uint256 _amount = LINK_TOKEN.balanceOf(address(this));
        if (_amount == 0) {
            revert CCIPTokenSender__NothingToWithdraw();
        }
        LINK_TOKEN.safeTransfer(_beneficiary, _amount);
    }

    function getCcipRouter() external view returns (address) {
        return address(CCIP_ROUTER);
    }

    function getDestinationChainSelector() external view returns (uint64) {
        return DESTINATION_CHAIN_SELECTOR;
    }

    function getUsdcTokenAddr() external view returns (address) {
        return address(USDC_TOKEN);
    }

    function getLinkTokenAddr() external view returns (address) {
        return address(LINK_TOKEN);
    }
}
