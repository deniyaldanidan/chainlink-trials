// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    address private minter;
    address private immutable I_OWNER;
    constructor(address _minter, address _owner) ERC20("MyToken", "MT") {
        minter = _minter;
        I_OWNER = _owner;
    }

    modifier _onlyOwner() {
        require(msg.sender == I_OWNER, "MyToken: Only owner allowed");
        _;
    }

    modifier _onlyMinter() {
        require(msg.sender == minter, "MyToken: Only minter allowed");
        _;
    }

    function mint(address _account, uint256 _value) external _onlyMinter {
        _mint(_account, _value);
    }

    function changeMinter(address _newMinter) external _onlyOwner {
        minter = _newMinter;
    }

    function getMinter() external view returns (address) {
        return minter;
    }

    function getOwner() external view returns (address) {
        return I_OWNER;
    }
}
