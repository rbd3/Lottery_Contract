// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {VRFConsumerBaseV2Plus} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title Raffle contract
 * @author Andry Narson
 * @notice This contract is for creating a sample raffle
 * @dev implements chainlink
 */
contract Raffle is VRFConsumerBaseV2Plus {
    /* error */
    error Raffle_SendMoreToEnterRaffle(); //add Raffle to see witch contract is the error. useful if more than on contract
    error TimeExpired();

    uint16 private constant requestConfirmations = 3;
    uint32 private numWords = 1;
    uint256 private immutable i_entranceFee;
    bytes32 private immutable s_keyHash;
    uint256 private immutable s_subscriptionId;
    uint32 private immutable s_callbackGasLimit;
    address payable[] private s_players;

    /* The duration of the lottery in seconds */
    uint256 private immutable i_interval;
    uint256 private s_lastTimestamp;

    /* event */
    event RaffleEntered(address indexed player);

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCordinator,
        bytes32 gasLane,
        uint256 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimestamp = block.timestamp;
        // s_vrfCoordinator.requestRandomWords();
        s_keyHash = gasLane;
        s_subscriptionId = subscriptionId;
        s_callbackGasLimit = callbackGasLimit;
    }

    function enterRaffle() external payable {
        // require(msg.value >= i_entranceFee, "Not enought ETH sent");
        // if (msg.value < i_entranceFee) {
        //     revert SendMoreToEnterRaffle();
        // }
        require(msg.value >= i_entranceFee, Raffle_SendMoreToEnterRaffle()); // since 0.8.26
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    function pickWinner() external {
        require(block.timestamp - s_lastTimestamp > i_interval, TimeExpired());

        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient
            .RandomWordsRequest({
                keyHash: s_keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: s_callbackGasLimit,
                numWords: numWords,
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            });

        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
    }

    //getters
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {}
}
