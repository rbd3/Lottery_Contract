// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract DeployRaffle is Script {
    function run() external returns (Raffle, HelperConfig) {
        return deployContract();
    }

    function deployContract() public returns (Raffle, HelperConfig) {
        // Deploy HelperConfig and get the network configuration
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        // Start broadcasting transactions (for deploying the Raffle contract)
        vm.startBroadcast();

        // Deploy the Raffle contract
        Raffle raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.vrfCordinator,
            config.gasLane,
            config.subscriptionId,
            config.callbackGasLimit
        );

        // Stop broadcasting transactions
        vm.stopBroadcast();

        // Return the deployed Raffle contract and HelperConfig
        return (raffle, helperConfig);
    }
}
