// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

/**
 * @title Raffle contract
 * @author Andry Narson
 * @notice This contract is for creating a sample raffle
 * @dev implements chainlink
 */
contract Raffle {
    error SendMoreToEnterRaffle();
    uint256 private immutable i_entranceFee;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function enterRaffle() public payable {
        // require(msg.value >= i_entranceFee, "Not enought ETH sent");
        // if (msg.value < i_entranceFee) {
        //     revert SendMoreToEnterRaffle();
        // }
        require(msg.value >= i_entranceFee, SendMoreToEnterRaffle()); // since 0.8.23
    }

    function pickWinner() public {}

    //getters
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
