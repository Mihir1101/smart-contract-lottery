// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/**
 * @title A sample raffle contract
 * @author Mihir Chandwani
 * @notice this contract is for creating sample raffle
 * @dev implements Chainlink VRFv2
 */
contract Raffle is VRFConsumerBaseV2 {
    error Raffle__NotEnoughETHSend();

    uint16 private constant REQUEST_CONFORMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    uint256 private immutable i_entranceFees;
    uint256 private immutable i_interval;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callBackGasLimit;

    address payable[] private s_players;
    uint256 private s_lastTimeStamp;

    /**Events*/
    event EnteredRaffle(address indexed player);

    constructor(
        uint256 entranceFees,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callBackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinator) {
        i_entranceFees = entranceFees;
        i_interval = interval;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callBackGasLimit = callBackGasLimit;
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFees) {
            revert Raffle__NotEnoughETHSend();
        }
        s_players.push(payable(msg.sender));

        emit EnteredRaffle(msg.sender);
    }

    function pickWinner() public {
        if ((block.timestamp - s_lastTimeStamp) < i_interval) {
            revert();
        }
        //get a random player
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFORMATIONS,
            i_callBackGasLimit,
            NUM_WORDS
        );
            function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
        ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);
    }
    }

    //Getter fees

    function getEntranceFees() external view returns (uint256) {
        return i_entranceFees;
    }
}
