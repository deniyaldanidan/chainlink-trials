# Chainlink Trials

## Commands:

### Forge test:

```bash
forge test --fork-url YOUR-ETH-SEPOLIA-RPC-URL -vvv
```


> sepolia price (data) feed address => 0x694AA1769357215DE4FAC081bf1f309aDC325306

## Next:
- [ ] Do a little revision
- [ ] Chainlink Local Study
- [ ] Build a Cross-Chain Dapp (Token-Transfer + Send-Data) to Simulate How things really work using Chainlink Local and Foundry + Solidity. It has to do:
	- [ ] Change a property on Contract deployed on Destination Network (Data Transfer)
	- [ ] Make an Transaction like Stake or Deposit on Destination Network (Token + Data Transfer)
- [ ] Finish the remaining Chainlink-lessons

> [!warning] 
> This repo got some library-errors. So continue rest of the course in another repo

> [!note] 
> Maybe try Hardhat instead of Foundry

> [!important]
> chainlink-brownie-contracts is deprecated, [so refer here](https://github.com/smartcontractkit/chainlink-brownie-contracts)
> 
> For installing different-versions use: 
> ```bash
> forge install openzeppelin-contracts-4.8.3=OpenZeppelin/openzeppelin-contracts@v4.8.3
> ```
> Also refer: 
> - https://docs.chain.link/chainlink-local/build/ccip/foundry/local-simulator-fork
> - https://github.com/Cyfrin/chainlink-fundamentals-cu/tree/main/chainlink-course-code/ccip
> - https://ccip.chain.link/


> [!note] 
> Also correct mappings in local vs-code's Path-Intellisense extension