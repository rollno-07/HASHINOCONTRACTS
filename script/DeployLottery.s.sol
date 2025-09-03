// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {Lottery} from "src/lottery.sol";

/**
 * Deployment script for Lottery
 *
 * Expects the following environment variables:
 * - DEPLOYER_PRIVATE_KEY: private key of the deployer (hex, no 0x or with 0x)
 * - INITIAL_TICKET_PRICE_WEI: uint, initial ticket price in wei (without the 20% add)
 * - INITIAL_WINNING_POOL_WEI: uint, initial jackpot pool in wei
 * - PLAYER_THRESHOLD: uint, number of players required to draw a winner
 *
 * Example:
 * forge script script/DeployLottery.s.sol \
 *   --rpc-url $SEPOLIA_RPC_URL \
 *   --broadcast \
 *   --verify \
 *   -vvvv
 */
contract DeployLottery is Script {
    function run() external returns (Lottery deployed) {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");

        uint256 initialTicketPriceWei = vm.envUint("INITIAL_TICKET_PRICE_WEI");
        uint256 initialWinningPoolWei = vm.envUint("INITIAL_WINNING_POOL_WEI");
        uint256 playerThreshold = vm.envUint("PLAYER_THRESHOLD");

        vm.startBroadcast(deployerPrivateKey);

        deployed = new Lottery(initialTicketPriceWei, initialWinningPoolWei, playerThreshold);

        vm.stopBroadcast();
    }
}
