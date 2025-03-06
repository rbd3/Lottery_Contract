// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/**
 * @title Raffle contract
 * @author Andry Narson
 * @notice This contract is for creating a sample raffle
 * @dev implements chainlink
 */
contract Raffle {
    uint256 private immutable i_entranceFee;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }
}
