// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint256, address) {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCordinator;
        (uint256 subId, ) = createSubscription(vrfCoordinator);

        return (subId, vrfCoordinator);
    }

    function createSubscription(
        address vrfCordinator
    ) public returns (uint256, address) {
        console.log("creating subscription on chain id: ", block.chainid);
        vm.startBroadcast();
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCordinator)
            .createSubscription();
        vm.stopBroadcast();
        console.log("your subscription id is ", subId);

        return (subId, vrfCordinator);
    }

    function run() public {
        createSubscriptionUsingConfig();
    }
}
