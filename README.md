🎟️ Lottery Smart Contract (Foundry)
A secure, transparent Lottery smart contract built with Foundry and Solidity. Players buy tickets with ETH; when enough tickets are sold, one winner receives the jackpot. Owner earns a percentage of each ticket sale.

✨ Features
ETH-based lottery with configurable ticket price, jackpot, and player threshold

Secure winner selection (demo pseudorandomness; upgrade to Chainlink VRF for production)

Owner earns a configurable cut

Fully tested and easy to deploy with Foundry

Emits events for easy frontend integration

⚡ Quick Start
Requirements
Foundry (Forge, Anvil, Cast)

Node.js & npm (for frontend integration)

Ethereum wallet & Sepolia testnet ETH

Installation
Clone and install dependencies:

git clone https://github.com/yourusername/lottery-contract-foundry.git
cd lottery-contract-foundry
forge install
forge build
forge test



<!-- Deployment (Sepolia example)
Update your .env file with: -->

SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_PROJECT_ID
DEPLOYER_PRIVATE_KEY=0xYOURPRIVATEKEY
INITIAL_TICKET_PRICE_WEI=10000000000000000
INITIAL_WINNING_POOL_WEI=5000000000000000
PLAYER_THRESHOLD=5

Deploy your contract to Sepolia:

forge script script/DeployLottery.s.sol:DeployLottery --rpc-url $SEPOLIA_RPC_URL --broadcast --private-key $DEPLOYER_PRIVATE_KEY

Interacting/Verifying
The ABI is generated at out/lottery.sol/Lottery.json for frontend use.

Use Cast or Etherscan to interact and verify.

🏗️ Project Structure
text
src/                # Solidity smart contract
test/               # Foundry tests
script/             # Deployment and management scripts
out/                # Artifacts (ABI, bytecode)
.env                # Secrets and config for deployment
foundry.toml        # Foundry configuration


📄 Example
text
Lottery.sol: (simplified)
function buyTicket() public payable;
function withdrawOwnerBalance() external onlyOwner;
function getPlayersCount() public view returns (uint256);
event TicketBought(address indexed player, uint256 lotteryId, uint256 amount);
event WinnerDrawn(address indexed winner, uint256 winningAmount, uint256 lotteryId);
🔒 Security & Notes
Only use pseudorandomness for testing; for production, upgrade to Chainlink VRF or similar secure randomness solutions.

Do not expose .env or private keys in public repos.

Review smart contract code for best practices and edge cases.

💡 Integrating With Frontend
Use the contract ABI from out/lottery.sol/Lottery.json.

Use wagmi, ethers.js, or web3.js for React or Next.js dApps.

📢 License
MIT

🙋‍♂️ Contact & Support
Raise an issue or contact vivekrawat0107@gmail.com 








