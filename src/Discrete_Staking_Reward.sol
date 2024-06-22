// SPDX-License-Ientifier: SEE LICENSE IN LICENSE

/**
 *
 * Things needed:
 *  total supply
 * balance of
 * rewardIndex
 * rewardEarned
 * Multiplier
 *
 *
 * Functions Required
 *
 * 1. Stake
 * 2. Unstake
 * 3. Claim
 * 4.CalculateReward
 * 5.CalcultaeRewardEarned
 * 6.UpdateReward
 */
pragma solidity ^0.8.13;

import {IERC20} from "./interface/IERC20.sol";

contract DiscreteStakingReward {
    IERC20 public immutable rewardToken;
    IERC20 public immutable stakingToken;

    //VARIABLES
    uint256 totalSupply;
    mapping(address => uint256) public balanceOf;
    uint256 private rewardIndex;
    mapping(address => uint256) public rewardEarned;
    uint256 private constant MULTIPLIER = 1e18;
    mapping(address => uint256) public rewardIndexOf;

    //CONSTRUCTOR
    constructor(address _rewardToken, address _stakingToken) {
        rewardToken = IERC20(_rewardToken);
        stakingToken = IERC20(_stakingToken);
    }

    //FUNCTONS

    function stake(uint256 amount) external {
        updateReward(msg.sender);
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        stakingToken.transferFrom(msg.sender, address(this), amount);
    }

    function unStake(uint256 amount) external {
        updateReward(msg.sender);
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        stakingToken.transfer(msg.sender, amount);
    }

    function Claim() external returns (uint256) {
        updateReward(msg.sender);
        uint256 reward = rewardEarned[msg.sender];
        if (reward > 0) {
            rewardEarned[msg.sender] = 0;
            rewardToken.transfer(msg.sender, reward);
        }
        return reward;
    }

    function calculateReward(address account) private view returns (uint256) {
        uint shares = balanceOf[account];
        return (shares * (rewardIndex - rewardIndexOf[account])) / MULTIPLIER;
    }

    function calculateRewardrewardEarned(
        address account
    ) external view returns (uint256) {
        return rewardEarned[account] + calculateReward(account);
    }

    function updateRewardIndex(uint256 reward) external {
        rewardToken.transferFrom(msg.sender, address(this), reward);
        rewardIndex += (reward * MULTIPLIER) / totalSupply;
    }

    function updateReward(address account) private {
        rewardEarned[account] += calculateReward(account);
        rewardIndexOf[account] = rewardIndex;
    }
}
