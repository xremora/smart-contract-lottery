// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// 0x9326BFA02ADD2366b30bacB125260Af641031331;
contract Lottery is Ownable, VRFConsumerBase {
    address payable[] public players;
    address payable public recentWinner;
    uint256 public randomness;

    uint152 public USDEntryFee;
    AggregatorV3Interface internal ethUdPriceFeed;
    uint256 public fee;
    bytes32 public keyhash;

    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }

    LOTTERY_STATE public lottery_state;

    constructor(
        address _priceFeedAddress,
        address _vrfCoordinator,
        address _link,
        uint256 _fee,
        bytes32 _keyhash
    ) public VRFConsumerBase(_vrfCoordinator, _link) {
        USDEntryFee = 50 * (10**18);
        ethUdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
        lottery_state = LOTTERY_STATE.CLOSED; // or just 1
        fee = _fee;
        keyhash = _keyhash;
    }

    function enter() public payable {
        // entry guard
        require(msg.value >= getEntranceFee(), "Not enough ETH!");
        require(lottery_state == LOTTERY_STATE.OPEN, "Not available!");
        players.push(msg.sender);
    }

    function getEntranceFee() public returns (uint256) {
        // TODO: integrate safemath ?
        // the `price` is in 8 decimals format
        (, int256 price, , , ) = ethUdPriceFeed.latestRoundData();
        uint256 adjustedPrice = uint256(price) * 10**10; // 18 decimals format
        uint256 costToEnter = (USDEntryFee * 10**18) / adjustedPrice;
        return costToEnter;
    }

    // managed by admin
    function startLottery() public onlyOwner {
        require(
            lottery_state == LOTTERY_STATE.CLOSED,
            "Can't start a new lottery now!"
        );
        lottery_state = LOTTERY_STATE.OPEN;
    }

    function endLottery() public onlyOwner {
        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;
        bytes32 requestId = requestRandomness(keyhash, fee);
    }

    function fulfillRandomness(bytes32 _requestId, uint256 _randomness)
        internal
        override
    {
        require(
            lottery_state == LOTTERY_STATE.CALCULATING_WINNER,
            "Youre not there yet!"
        );
        require(_randomness > 0, "random-not-found");
        uint256 indexOfWinner = _randomness % players.length;
        recentWinner = players[indexOfWinner];
        recentWinner.transfer(address(this).balance);

        // reset
        players = new address payable[](0);
        lottery_state = LOTTERY_STATE.CLOSED;
        randomness = _randomness;
    }
}
