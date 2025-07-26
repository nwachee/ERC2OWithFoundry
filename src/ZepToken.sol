//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ZepToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("ZepToken", "ZEP") {
        _mint(msg.sender, initialSupply);
    }
}
