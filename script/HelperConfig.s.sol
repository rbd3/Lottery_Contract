// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";

abstract contract CodeCostants {
    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 1115511;
    uint256 public constant LOCAL_CHAIN_ID = 31337
}

contract HelperConfig is CodeCostants, Script {
   error HelperConfig_invalidChainId();

    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCordinator;
        bytes32 gasLane;
        uint256 subscriptionId;
        uint32 callbackGasLimit;
    }

    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
    }

    function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        if (networkConfigs[chainId].vrfCordinator != address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == LOCAL_CHAIN_ID) {
            //envil
        } else {
            revert HelperConfig_invalidChainId();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30, // 30sec
            vrfCordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B, //from https://docs.chain.link/vrf/v2-5/supported-networks
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: 0
            callbackGasLimit:500000, // 500 000 gas

        }
        )
    }

    function createOrGetAnvilEthConfig() public returns (NetworkConfig memory) {
        //check if networkConfig exist
        if (localNetworkConfig.vrfCordinator != address(0)) {
            return localNetworkConfig;
        }
    }
}
