// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Lottery} from "../src/lottery.sol";

contract LotteryTest is Test {
    Lottery lottery;
    address alice = address(0xA11CE);
    address bob = address(0xB0B);

    // Allow this test contract to receive ETH (owner receives 80% in buyTicket)
    receive() external payable {}

    uint256 initialTicketPrice = 0.01 ether;
    uint256 initialWinningPool = 0.002 ether; // example
    uint256 threshold = 2;

    function setUp() public {
        lottery = new Lottery(initialTicketPrice, initialWinningPool, threshold);
        // deal some ETH to test users
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }

    function testConstructorSetsValues() public view {
        assertEq(lottery.initialTicketPrice(), initialTicketPrice);
        assertEq(lottery.playerThreshold(), threshold);
        assertEq(lottery.currentWinningPool(), initialWinningPool);
        // ticketPrice = initial + 20%
        assertEq(lottery.ticketPrice(), initialTicketPrice + (initialTicketPrice * 20) / 100);
    }

    function testBuyTicketEmitsEventAndAddsPlayer() public {
        vm.prank(alice);
        vm.expectEmit(true, false, false, true);
        emit Lottery.TicketBought(alice, lottery.lotteryId(), lottery.ticketPrice());
        lottery.buyTicket{value: lottery.ticketPrice()}();

        assertEq(lottery.getPlayersCount(), 1);
    }

    function testBuyTicketRevertsOnWrongPrice() public {
        vm.prank(alice);
        vm.expectRevert(bytes("Incorrect ticket price sent"));
        lottery.buyTicket{value: 1 wei}();
    }

    function testThresholdTriggersWinnerAndResets() public {
        // First buy
        vm.prank(alice);
        lottery.buyTicket{value: lottery.ticketPrice()}();
        // Second buy triggers draw
        vm.prank(bob);
        lottery.buyTicket{value: lottery.ticketPrice()}();

        // After draw, players reset and lotteryId increments
        assertEq(lottery.getPlayersCount(), 0);
        assertEq(lottery.winner() != address(0), true);
        assertEq(lottery.lotteryId(), 2);
    }
}
