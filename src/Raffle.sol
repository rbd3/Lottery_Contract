// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {VRFConsumerBaseV2Plus} from
    "lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
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
    error Raffle_TimeExpired();
    error Raffle_TransfertFailed();
    error Raffle_RaffleNotOpen();
    error Raffle_UpkeepNeeded(uint256 balance, uint256 playerLength, uint256 raffleState);

    /* Type declaration */
    enum RaffleState {
        OPEN, //0
        CALCULATING //1

    }
    /* State variable */

    uint16 private constant requestConfirmations = 3;
    uint32 private numWords = 1;
    uint256 private immutable i_entranceFee;
    bytes32 private immutable s_keyHash;
    uint256 private immutable s_subscriptionId;
    uint32 private immutable s_callbackGasLimit;
    address payable[] private s_players;
    address private s_recentWinner;
    RaffleState private s_raffleState;
    /* The duration of the lottery in seconds */
    uint256 private immutable i_interval;
    uint256 private s_lastTimestamp;

    /* event */
    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);
    event RequestedRaffleWinner(uint256 indexed requestId);

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
        s_raffleState = RaffleState.OPEN; // same as RaffleState(0)
    }

    function enterRaffle() external payable {
        // require(msg.value >= i_entranceFee, "Not enought ETH sent");
        // if (msg.value < i_entranceFee) {
        //     revert SendMoreToEnterRaffle();
        // }
        require(msg.value >= i_entranceFee, Raffle_SendMoreToEnterRaffle()); // since 0.8.26
        require(s_raffleState == RaffleState.OPEN, Raffle_RaffleNotOpen());
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    function performUpkeep(bytes calldata /* performData */ ) external {
        // require(
        //     block.timestamp - s_lastTimestamp > i_interval,
        //     Raffle_TimeExpired()
        // );
        (bool upkeepNeeded,) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert Raffle_UpkeepNeeded(address(this).balance, s_players.length, uint256(s_raffleState));
        }
        s_raffleState = RaffleState.CALCULATING;

        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
            keyHash: s_keyHash,
            subId: s_subscriptionId,
            requestConfirmations: requestConfirmations,
            callbackGasLimit: s_callbackGasLimit,
            numWords: numWords,
            // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
            extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
        });

        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
        emit RequestedRaffleWinner(requestId);
    }

    //getters
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function getRaffleState() external view returns (RaffleState) {
        return s_raffleState;
    }

    function getPlayer(uint256 indexOfPlayer) external view returns (address) {
        return s_players[indexOfPlayer];
    }

    function getLastTimeStamp() external view returns (uint256) {
        return s_lastTimestamp;
    }

    function getRecentWinner() external view returns (address) {
        return s_recentWinner;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_lastTimestamp = block.timestamp;
        emit WinnerPicked(recentWinner);

        (bool success,) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle_TransfertFailed();
        }
    }

    //function to pick a winner
    function checkUpkeep(bytes memory /* checkData */ )
        public
        view
        returns (bool upkeepNeeded, bytes memory /* performData */ )
    {
        bool timeHasPassed = (block.timestamp - s_lastTimestamp) >= i_interval;
        bool isOpen = s_raffleState == RaffleState.OPEN;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayer = s_players.length > 0;
        upkeepNeeded = timeHasPassed && isOpen && hasBalance && hasPlayer;

        return (upkeepNeeded, "");
    }
}
