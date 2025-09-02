// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

// This is a simple lottery contract.
contract Lottery is Ownable {
    // State variables to manage the lottery
    uint256 public initialTicketPrice; // The base price for a single lottery ticket
    uint256 public ticketPrice;        // The actual amount a player must send, including the 20% for the jackpot
    uint256 public currentWinningPool; // The total winning amount, which grows with each participant
    uint256 public constant JACKPOT_CUT_PERCENTAGE = 20; // 20% of the ticket price goes to the jackpot
    uint256 public constant OWNER_CUT_PERCENTAGE = 80;    // 80% of the ticket price goes to the owner
    uint256 public playerThreshold;    // The number of players required to trigger the winner drawing
    uint256 public lotteryId = 1;      // An ID to track each lottery round
    address public winner;             // The address of the winner for the current round
    address[] public players;          // An array to store all participating player addresses

    // Events to log important actions on the blockchain
    event TicketBought(address indexed player, uint256 lotteryId, uint256 amount);
    event WinnerDrawn(address indexed winner, uint256 winningAmount, uint256 lotteryId);
    event LotteryReset(uint256 newLotteryId);

    // The constructor sets the initial parameters of the lottery.
    constructor(uint256 _initialTicketPrice, uint256 _initialWinningPool, uint256 _playerThreshold) Ownable(msg.sender) {
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

        // Distribute the funds
        // Send 80% of the ticket price to the contract owner
        uint256 ownerCut = (msg.value * OWNER_CUT_PERCENTAGE) / 100;
        payable(owner()).transfer(ownerCut);

        // Add the remaining 20% to the winning pool
        uint256 jackpotCut = (msg.value * JACKPOT_CUT_PERCENTAGE) / 100;
        currentWinningPool += jackpotCut;

        emit TicketBought(msg.sender, lotteryId, msg.value);

        // Check if the player threshold has been reached.
        if (players.length >= playerThreshold) {
            _drawWinner();
        }
    }

    // New function to get the current number of players
    function getPlayersCount() public view returns (uint256) {
        return players.length;
    }

    // This is a private function to select a winner and pay them.
    function _drawWinner() private {
        // Use a pseudo-random number generator to select a winner.
        // NOTE: This is a simplified approach for demonstration purposes on a testnet.
        // For a production-ready contract, a more secure, on-chain randomness solution
        // like Chainlink VRF is recommended to prevent front-running.
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, players.length, lotteryId)));
        uint256 winnerIndex = randomNumber % players.length;

        winner = players[winnerIndex];

        // Pay the winner the full amount from the winning pool.
        payable(winner).transfer(currentWinningPool);

        // Emit a winner drawn event and reset the lottery for the next round.
        emit WinnerDrawn(winner, currentWinningPool, lotteryId);
        _resetLottery();
    }

    // This private function resets all state variables for a new round.
    function _resetLottery() private {
        players = new address[](0);
        currentWinningPool = initialTicketPrice + (initialTicketPrice * JACKPOT_CUT_PERCENTAGE) / 100;
        lotteryId++;
        winner = address(0);
        emit LotteryReset(lotteryId);
    }
}