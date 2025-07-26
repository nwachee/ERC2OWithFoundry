//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {ZepToken} from "../src/ZepToken.sol";

contract DeployZepToken is Script {
    uint256 constant INITAL_SUPPLY = 1000 ether;

    function run() external returns (ZepToken) {
        vm.startBroadcast();
        ZepToken zepto = new ZepToken(INITAL_SUPPLY);
        vm.stopBroadcast();

        return zepto;
    }
}
