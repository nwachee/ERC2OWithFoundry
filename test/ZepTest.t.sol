// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {ZepToken} from "../src/ZepToken.sol";
import {DeployZepToken} from "../script/DeployZepToken.s.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract ZepTest is StdCheats, Test {
    ZepToken public zepToken;
    DeployZepToken public deployer;

    address king = makeAddr("king");
    address queen = makeAddr("queen");

    uint256 constant STARTING_BALANCE = 1000 ether;
    uint256 public constant INITIAL_SUPPLY = 1_000_000 ether;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function setUp() public {
        deployer = new DeployZepToken();
        zepToken = deployer.run();

        vm.prank(msg.sender);
        zepToken.transfer(king, STARTING_BALANCE);
        vm.prank(msg.sender);
        zepToken.transfer(queen, STARTING_BALANCE);
    }

    function test_InitialSupply() public view {
        assertEq(zepToken.totalSupply(), deployer.INITAL_SUPPLY());
    }

    function test_UsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(zepToken)).mint(address(this), 1);
    }

    function test_BalanceIsCorrectForUserAfterTransfer() public view {
        assertEq(STARTING_BALANCE, zepToken.balanceOf(king));
        assertEq(STARTING_BALANCE, zepToken.balanceOf(queen));
    }

    function test_ApproveAndTransferFromSucceeds() public {
        uint256 initialAllowance = 1000;

        vm.prank(king);
        zepToken.approve(queen, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(queen);
        zepToken.transferFrom(king, queen, transferAmount);
    }

    function test_RevertWhen_MintIsCalledExternally() public {
        vm.expectRevert(); // Should fail because mint is internal
        MintableToken(address(zepToken)).mint(address(this), 1 ether);
    }

    function test_TransferUpdatesBalancesCorrectly() public {
        vm.prank(queen);
        zepToken.transfer(king, 100 ether);

        assertEq(zepToken.balanceOf(queen), 900 ether);
        assertEq(zepToken.balanceOf(king), 1100 ether);
    }

    function test_RevertWhen_TransferAmountExceedsBalance() public {
        vm.prank(queen);
        vm.expectRevert();
        zepToken.transfer(king, 2000 ether); // Should revert
    }

    function test_ApproveAndCheckAllowance() public {
        vm.prank(queen);
        zepToken.approve(king, 500 ether);

        uint256 allowance = zepToken.allowance(queen, king);
        assertEq(allowance, 500 ether);
    }

    function test_TransferFromReducesAllowanceAndTransfers() public {
        vm.startPrank(queen);
        zepToken.approve(king, 500 ether);
        vm.stopPrank();

        vm.prank(king);
        zepToken.transferFrom(queen, king, 300 ether);

        assertEq(zepToken.balanceOf(king), 1300 ether);
        assertEq(zepToken.balanceOf(queen), 700 ether);
        assertEq(zepToken.allowance(queen, king), 200 ether);
    }

    function test_RevertWhen_TransferFromWithoutApproval() public {
        vm.prank(king);
        vm.expectRevert();
        zepToken.transferFrom(queen, king, 300 ether); // No approve call
    }

    function test_TransferEmitsTransferEvent() public {
        vm.prank(queen);
        vm.expectEmit(true, true, false, true);
        emit Transfer(queen, king, 100 ether);
        zepToken.transfer(king, 100 ether);
    }

    function test_ApproveEmitsApprovalEvent() public {
        vm.prank(queen);
        vm.expectEmit(true, true, false, true);
        emit Approval(queen, king, 100 ether);
        zepToken.approve(king, 100 ether);
    }
}
