# Eth_Global_Bangkok
Project Hackaton Eth Global

Sepolia Blockscout Verifcation Smart Contract

https://eth-sepolia.blockscout.com/address/0x024Ec2582869Cf84D6508792237B2b6E061adFBc?tab=txs

his project, EthPricePrediction, was built using Solidity, leveraging the Ethereum blockchain to ensure decentralization and transparency. Here are the key technical details and technologies used in its development:

Technologies and Their Role:
Smart Contracts with Solidity

The core functionality, including prediction submissions, pool management, and reward distribution, is implemented in Solidity.
It employs mapping structures and arrays to manage user predictions and daily participants efficiently.
Oracle Integration with Chronicle

The Chronicle oracle is used to fetch the ETH/USD price data securely and reliably.
Chronicle was selected for its strong reputation and robust price data feed system, ensuring accuracy and fairness in the competition.
Ethereum Blockchain

The Ethereum mainnet (or testnet during development) is the backbone of the application, ensuring decentralized and immutable operation.
Event-driven Architecture

Solidity events are utilized to log key actions like new predictions and winner announcements. This design facilitates integration with a front-end and provides transparency for participants.
Custom Interfaces

Two interfaces, IChronicle and ISelfKisser, enable smooth interactions with the Chronicle oracle and its access manager, abstracting external dependencies.
How the Technologies Are Pieced Together:
The Chronicle oracle is integrated using its custom interface to fetch ETH/USD price data, which drives the winner selection mechanism.
Participants interact with the contract directly via Ethereum wallets (e.g., MetaMask), submitting predictions along with ETH stakes.
The contract processes submissions, calculates winners based on the closest match to the oracle's data, and handles reward distribution seamlessly.
Ownership controls are implemented for administrative functions like emergency winner selection or contract management.
Hacky or Noteworthy Aspects:
Dynamic Oracle Authentication

The integration with ISelfKisser for oracle self-authentication (via the selfKiss method) ensures dynamic and secure access management, making the contract robust and scalable.
Optimized Daily Reset

Instead of complex off-chain handling, the _resetDay function efficiently resets the state variables for a new day, minimizing gas costs while ensuring correctness.
Flexibility for Immediate Winner Selection

An emergency winner selection mechanism (selectWinnerImmediately) allows the owner to intervene when necessary, ensuring operational continuity in edge cases.
The combination of these technologies and design principles makes EthPricePrediction a highly efficient, secure, and engaging platform for ETH price speculation, showcasing the power of blockchain and oracles in gamified financial applications.






