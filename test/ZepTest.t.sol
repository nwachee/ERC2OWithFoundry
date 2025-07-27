//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {ZepToken} from "../src/ZepToken.sol";
import {DeployZepToken} from "../script/DeployZepToken.s.sol";

contract ZepTest is Test {
    ZepToken public zepToken;
    DeployZepToken public deployer;

    address king = makeAddr("king");
    address queen = makeAddr("queen");

    uint256 constant STARTING_BALANCE = 1000 ether;

    function setUp() public {
        deployer = new DeployZepToken();
        zepToken = deployer.run();  

        vm.prank(msg.sender);
        zepToken.transfer(king, STARTING_BALANCE);      
    }

    function testInitialBalance() public view {
        assertEq(STARTING_BALANCE, zepToken.balanceOf(king));
    }

    function testAllowancesWork() public {
    uint256 initialAllowance = 1000;

    // King approves Queen to spend 1000 tokens.
    vm.prank(king);
    zepToken.approve(queen, initialAllowance);

    uint256 transferAmount = 500;

    vm.prank(queen);
    zepToken.transferFrom(king, queen, transferAmount);
}


}