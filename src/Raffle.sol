// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

/**
 * @title Raffle contract
 * @author Andry Narson
 * @notice This contract is for creating a sample raffle
 * @dev implements chainlink
 */
contract Raffle {
    error Raffle_SendMoreToEnterRaffle(); //add Raffle to see witch contract is the error. useful if more than on contract
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;
    /* event */
    event RaffleEntered(address indexed player);

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function enterRaffle() public payable {
        // require(msg.value >= i_entranceFee, "Not enought ETH sent");
        // if (msg.value < i_entranceFee) {
        //     revert SendMoreToEnterRaffle();
        // }
        require(msg.value >= i_entranceFee, Raffle_SendMoreToEnterRaffle()); // since 0.8.23
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    function pickWinner() public {}

    //getters
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
