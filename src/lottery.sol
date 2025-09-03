// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// This is a simple lottery contract.
contract Lottery is Ownable {
    // State variables to manage the lottery
    uint256 public initialTicketPrice; // The base price for a single lottery ticket
    uint256 public ticketPrice; // The actual amount a player must send, including the 20% for the jackpot
    uint256 public currentWinningPool; // The total winning amount, which grows with each participant
    uint256 public constant JACKPOT_CUT_PERCENTAGE = 20; // 20% of the ticket price goes to the jackpot
    uint256 public constant OWNER_CUT_PERCENTAGE = 80; // 80% of the ticket price goes to the owner
    uint256 public playerThreshold; // The number of players required to trigger the winner drawing
    uint256 public lotteryId = 1; // An ID to track each lottery round
    address public winner; // The address of the winner for the current round
    address[] public players; // An array to store all participating player addresses
    uint256 public ownerBalance; // Tracks owner earnings from ticket sales

    // Events to log important actions on the blockchain
    event TicketBought(address indexed player, uint256 lotteryId, uint256 amount);
    event WinnerDrawn(address indexed winner, uint256 winningAmount, uint256 lotteryId);
    event LotteryReset(uint256 newLotteryId);
    event OwnerWithdraw(uint256 amount);

    // The constructor sets the initial parameters of the lottery.
    constructor(uint256 _initialTicketPrice, uint256 _initialWinningPool, uint256 _playerThreshold)
        Ownable(msg.sender)
    {
        require(_initialTicketPrice > 0, "Ticket price must be greater than 0");
        require(_playerThreshold > 0, "Player threshold must be greater than 0");

        initialTicketPrice = _initialTicketPrice;
        playerThreshold = _playerThreshold;
        currentWinningPool = _initialWinningPool;

        // The ticket price is the initial price + 20% for the jackpot.
        ticketPrice = initialTicketPrice + (initialTicketPrice * JACKPOT_CUT_PERCENTAGE) / 100;
    }

    // Function for players to buy a ticket.
    function buyTicket() public payable {
        // Ensure the player sends the exact ticket price.
        require(msg.value == ticketPrice, "Incorrect ticket price sent");

        // Add the player to the list of participants.
        players.push(msg.sender);

        // Calculate owner's and jackpot's share
        uint256 ownerCut = (msg.value * OWNER_CUT_PERCENTAGE) / 100;
        uint256 jackpotCut = (msg.value * JACKPOT_CUT_PERCENTAGE) / 100;

        // Record owner's cut in balance instead of sending immediately
        ownerBalance += ownerCut;

        // Add the jackpot cut to the winning pool
        currentWinningPool += jackpotCut;

        emit TicketBought(msg.sender, lotteryId, msg.value);

        // Check if the player threshold has been reached.
        if (players.length >= playerThreshold) {
            _drawWinner();
        }
    }

    // Allows owner to withdraw accumulated earnings
    function withdrawOwnerBalance() external onlyOwner {
        require(ownerBalance > 0, "No balance to withdraw");
        uint256 amount = ownerBalance;
        ownerBalance = 0;
        payable(owner()).transfer(amount);
        emit OwnerWithdraw(amount);
    }

    // Returns the current number of players
    function getPlayersCount() public view returns (uint256) {
        return players.length;
    }

    // Private function to select a winner and pay them.
    function _drawWinner() private {
        // Use a pseudo-random number generator to select a winner.
        // NOTE: For production, use a secure randomness source like Chainlink VRF.
        uint256 randomNumber =
            uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, players.length, lotteryId)));
        uint256 winnerIndex = randomNumber % players.length;

        winner = players[winnerIndex];

        // Ensure the contract has enough balance to pay the winner
        require(address(this).balance >= currentWinningPool, "Insufficient funds");

        // Pay the winner the full amount from the winning pool.
        payable(winner).transfer(currentWinningPool);

        emit WinnerDrawn(winner, currentWinningPool, lotteryId);

        // Reset the lottery for the next round
        _resetLottery();
    }

    // Private function to reset all state variables for a new round.
    function _resetLottery() private {
        players = new address[](0);
        currentWinningPool = initialTicketPrice + (initialTicketPrice * JACKPOT_CUT_PERCENTAGE) / 100;
        lotteryId++;
        winner = address(0);
        emit LotteryReset(lotteryId);
    }

    // Optional: to accept any accidentally sent ETH
    receive() external payable {}
}
