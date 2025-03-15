// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract RaffleTest is Test {
    Raffle public raffle;
    HelperConfig public helperConfig;
    address public PLAYER = makeAddr("player");
    uint256 public STARTING_PLAYER_BALANCE = 10 ether;

    uint256 entranceFee;
    uint256 interval;
    address vrfCordinator;
    bytes32 gasLane;
    uint256 subscriptionId;
    uint32 callbackGasLimit;

    /* event */
    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);
    event RequestedRaffleWinner(uint256 indexed requestId);

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.deployContract();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCordinator = config.vrfCordinator;
        gasLane = config.gasLane;
        subscriptionId = config.subscriptionId;
        callbackGasLimit = config.callbackGasLimit;

        vm.deal(PLAYER, STARTING_PLAYER_BALANCE);
    }

    /*//////////////////////////////////////////////////////////////
                                GETTERS
    //////////////////////////////////////////////////////////////*/

    function testRaffleStateInitialized() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN); //check initiale state
    }

    function testRaffleEntranceFee() public view {
        //assert(raffle.getEntranceFee() == entranceFee);
        assertEq(raffle.getEntranceFee(), entranceFee);
    }

    /*//////////////////////////////////////////////////////////////
                              ENTER RAFFLE
    //////////////////////////////////////////////////////////////*/

    modifier raffleEntered() {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        _;
    }

    function testRevertWhenNotEnoughEth() public {
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle_SendMoreToEnterRaffle.selector);
        raffle.enterRaffle();
    }

    function testRaffleRecordsPlayerEnter() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        address recordsPlayer = raffle.getPlayer(0);
        assert(recordsPlayer == PLAYER);
    }

    function testEnterRaffleEvent() public {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(raffle));

        emit RaffleEntered(PLAYER);

        raffle.enterRaffle{value: entranceFee}();
    }

    function testDontAllowPlayerWhenRaffleCalculating() public raffleEntered {
        raffle.performUpkeep("");
        vm.expectRevert(Raffle.Raffle_RaffleNotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }

    /*//////////////////////////////////////////////////////////////
                              CHECK UPKEEP
    //////////////////////////////////////////////////////////////*/

    function testUpKeepIfNoEnoughBalance() public {
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        (bool upKeepNeeded, ) = raffle.checkUpkeep("");
        assert(!upKeepNeeded);
    }

    function testCheckUpkeepIfRaffleIsntOpen() public raffleEntered {
        raffle.performUpkeep("");

        (bool upKeepNeeded, ) = raffle.checkUpkeep("");
        assert(!upKeepNeeded);
    }

    /*//////////////////////////////////////////////////////////////
                             PERFORM UPKEEP
    //////////////////////////////////////////////////////////////*/

    function testPerformUpkeepRun() public raffleEntered {
        raffle.performUpkeep("");
    }

    function testPerformUpkeepIfCheckUpkeepIsFalse() public {
        uint256 currentBalance = 0;
        uint256 numPlayer = 0;
        Raffle.RaffleState rState = raffle.getRaffleState();
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        currentBalance = currentBalance + entranceFee;
        numPlayer = 1;

        vm.expectRevert(
            abi.encodeWithSelector(
                Raffle.Raffle_UpkeepNeeded.selector,
                currentBalance,
                numPlayer,
                rState
            )
        );
        raffle.performUpkeep("");
    }

    function testPerformUpkeedAndEmitRequestId() public raffleEntered {
        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        Raffle.RaffleState rState = raffle.getRaffleState();
        assert(uint256(requestId) > 0);
        assert(uint256(rState) == 1);
    }

    /*//////////////////////////////////////////////////////////////
                           FULFILLRANDOMWORDS
    //////////////////////////////////////////////////////////////*/

    function testFulfillWordsCanOnlyCalledAfterPerforUpKeep(
        uint256 requestId //add requestId for fuzz test
    ) public raffleEntered {
        vm.expectRevert(VRFCoordinatorV2_5Mock.InvalidRequest.selector);
        VRFCoordinatorV2_5Mock(vrfCordinator).fulfillRandomWords(
            requestId,
            address(raffle)
        );
    }

    function testFulfillRandomWordsPickWinnerResetaAndSendMoney()
        public
        raffleEntered
    {
        uint256 additionalEntrants = 3;
        uint256 startingIndex = 1;
        address expectedWinner = address(1);

        for (
            uint256 i = startingIndex;
            i < startingIndex + additionalEntrants;
            i++
        ) {
            address newPlayer = address(uint160(i));
            hoax(newPlayer, 1 ether);
            raffle.enterRaffle{value: entranceFee}();
        }

        uint256 startTimeStamp = raffle.getLastTimeStamp();
        uint256 winnerStatingBalance = expectedWinner.balance;
        vm.recordLogs();
        raffle.performUpkeep("");

        Vm.Log[] memory entries = vm.getRecordedLogs();
        require(entries.length > 1, "Not enough log entries recorded.");
        bytes32 requestId = entries[1].topics[1];

        VRFCoordinatorV2_5Mock(vrfCordinator).fulfillRandomWords(
            uint256(requestId),
            address(raffle)
        );

        address recentWinner = raffle.getRecentWinner();
        Raffle.RaffleState rState = raffle.getRaffleState();
        uint256 winnerBalance = recentWinner.balance;
        uint256 lastTimeStamp = raffle.getLastTimeStamp();
        uint256 prize = entranceFee * (additionalEntrants + 1);

        assert(recentWinner == expectedWinner);
        assert(uint256(rState) == 0);
        assert(winnerBalance == winnerStatingBalance + prize);
        assert(lastTimeStamp > startTimeStamp);
    }
}
