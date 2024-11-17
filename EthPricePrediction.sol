// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/**
 * @title EthPricePrediction
 * @notice ETH/USD price prediction contract with a daily betting pool.
 */
contract EthPricePrediction {
    /// @notice The Chronicle ETH/USD oracle.
    IChronicle public immutable chronicle;

    /// @notice The Chronicle oracle access manager.
    ISelfKisser public immutable selfKisser;

    /// @notice Address of the contract owner.
    address public owner;

    /// @notice Mapping to store predictions per participant.
    mapping(address => uint256) public predictions;

    /// @notice Total amount wagered in the pool.
    uint256 public totalPool;

    /// @notice Address of the day's winner.
    address public dailyWinner;

    /// @notice Record of daily predictions.
    address[] public participants;

    /// @notice Timestamp of the current day's start.
    uint256 public dayStart;

    /// @notice Event to log new predictions.
    event NewPrediction(address indexed participant, uint256 prediction);

    /// @notice Event to announce the winner.
    event WinnerAnnounced(address indexed winner, uint256 reward);

    /// @notice Modifier to restrict access to the owner.
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(address chronicle_, address selfKisser_) {
        chronicle = IChronicle(chronicle_);
        selfKisser = ISelfKisser(selfKisser_);
        selfKisser.selfKiss(address(chronicle));

        // Set the deployer as the contract owner.
        owner = msg.sender;

        // Start the current day.
        dayStart = block.timestamp;
    }

    /// @notice Allows participants to make a prediction.
    /// @param prediction The ETH/USD price predicted by the participant.
    function makePrediction(uint256 prediction) external payable {
        require(msg.value > 0, "Must send ETH to participate");
        require(
            block.timestamp < dayStart + 1 days,
            "The time for predictions has ended"
        );

        // Record the prediction.
        predictions[msg.sender] = prediction;
        participants.push(msg.sender);

        // Update the pool.
        totalPool += msg.value;

        emit NewPrediction(msg.sender, prediction);
    }

    /// @notice Ends the day, calculates the winner, and distributes the reward.
    function finalizeDay() external {
        require(
            block.timestamp >= dayStart + 1 days,
            "The current day is not yet finished"
        );
        _calculateWinner();
    }

    /// @notice Allows the owner to select the winner immediately.
    function selectWinnerImmediately() external onlyOwner {
        _calculateWinner();
    }

    /// @notice Calculates the winner and distributes the reward.
    function _calculateWinner() private {
        require(participants.length > 0, "No participants");

        // Get the current price from the oracle.
        uint256 oraclePrice = chronicle.read();

        // Determine the winner.
        uint256 closestDifference = type(uint256).max;
        address winner;

        for (uint256 i = 0; i < participants.length; i++) {
            address participant = participants[i];
            uint256 prediction = predictions[participant];
            uint256 difference = _absoluteDifference(prediction, oraclePrice);

            if (difference < closestDifference) {
                closestDifference = difference;
                winner = participant;
            }
        }

        // Update state variables.
        dailyWinner = winner;
        uint256 reward = (totalPool * 90) / 100; // Winner receives 90% of the pool.

        // Transfer the reward to the winner.
        payable(winner).transfer(reward);

        emit WinnerAnnounced(winner, reward);

        // Reset for the next day.
        _resetDay();
    }

    /// @notice Calculates the absolute difference between two numbers.
    function _absoluteDifference(uint256 a, uint256 b)
        private
        pure
        returns (uint256)
    {
        return a > b ? a - b : b - a;
    }

    /// @notice Resets variables for a new day.
    function _resetDay() private {
        for (uint256 i = 0; i < participants.length; i++) {
            delete predictions[participants[i]];
        }

        delete participants;
        totalPool = 0;
        dayStart = block.timestamp;
    }

    /// @notice Allows the owner to transfer contract ownership.
    /// @param newOwner Address of the new owner.
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is invalid");
        owner = newOwner;
    }

    /// @notice Reads the current ETH/USD price from the oracle.
    function read() external view returns (uint256 val) {
        return chronicle.read();
    }
}

// Existing interfaces.
interface IChronicle {
    function read() external view returns (uint256 value);
}

interface ISelfKisser {
    function selfKiss(address oracle) external;
}
