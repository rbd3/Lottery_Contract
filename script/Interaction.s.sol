// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig, CodeCostants} from "script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from
    "lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint256, address) {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCordinator;
        (uint256 subId,) = createSubscription(vrfCoordinator);

        return (subId, vrfCoordinator);
    }

    function createSubscription(address vrfCordinator) public returns (uint256, address) {
        vm.startBroadcast();
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCordinator).createSubscription();
        vm.stopBroadcast();

        return (subId, vrfCordinator);
    }

    function run() public {
        createSubscriptionUsingConfig();
    }
}

contract FundSubscription is CodeCostants, Script {
    uint256 public constant FUND_AMOUNT = 3 ether; // equal 3 link

    function run() public {
        fundSubscriptionUsingConfig();
    }

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCordinator;
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
        address linkToken = helperConfig.getConfig().link;
        fundSubscription(vrfCoordinator, subscriptionId, linkToken);
    }

    function fundSubscription(address vrfCoordinator, uint256 subscriptionId, address linkToken) public {
        if (block.chainid == LOCAL_CHAIN_ID) {
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subscriptionId, FUND_AMOUNT * 100);
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
            LinkToken(linkToken).transferAndCall(vrfCoordinator, FUND_AMOUNT, abi.encode(subscriptionId));
            vm.stopBroadcast();
        }
    }
}

contract AddConsummer is Script {
    function run() external {
        address mostRecentDeploy = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);
        addConsummerUsingConfig(mostRecentDeploy);
    }

    function addConsummerUsingConfig(address mostRecentDeploy) public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCordinator;
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
        addConsummer(mostRecentDeploy, vrfCoordinator, subscriptionId);
    }

    function addConsummer(address contractToAddTovrf, address vrfCoordinator, uint256 subscriptionId) public {
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(subscriptionId, contractToAddTovrf);
        vm.stopBroadcast();
    }
}
