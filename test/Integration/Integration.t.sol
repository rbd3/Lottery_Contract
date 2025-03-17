// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import {CreateSubscription} from "script/Interaction.s.sol";
import {FundSubscription} from "script/Interaction.s.sol";
import {AddConsummer} from "script/Interaction.s.sol";
import {VRFCoordinatorV2_5Mock} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract IntegrationTest is Test {
    CreateSubscription createSubscription;
    FundSubscription fundSubscription;
    AddConsummer addConsummer;
    HelperConfig helperConfig;
    LinkToken linkToken;

    function setUp() public {
        helperConfig = new HelperConfig();
        createSubscription = new CreateSubscription();
        fundSubscription = new FundSubscription();
        addConsummer = new AddConsummer();
    }

    function testCreateSubscription() public {
        (uint256 subId, address vrfCoordinator) = createSubscription
            .createSubscriptionUsingConfig();
        assertGt(subId, 0, "Subscription ID should be greater than 0");
        assertTrue(
            vrfCoordinator != address(0),
            "VRF Coordinator address should not be zero"
        );
    }

    function testAddConsumer() public {
        (uint256 subId, address vrfCordinator) = createSubscription
            .createSubscriptionUsingConfig();
        address consumerContract = address(this);
        addConsummer.addConsummer(consumerContract, vrfCordinator, subId);
        console.log("Consumer added successfully");
    }

    function testRunCreatSubscription() public {
        createSubscription.run();
        (uint256 subId, address vrfCoordinator) = createSubscription
            .createSubscriptionUsingConfig();
        assertGt(subId, 0, "Subscription ID should be greater than 0");
        assertTrue(
            vrfCoordinator != address(0),
            "VRF Coordinator address should not be zero"
        );
    }
}
