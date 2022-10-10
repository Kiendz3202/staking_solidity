// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Context.sol";

interface Token {
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (uint256);
}

contract StakeMK is Ownable, ReentrancyGuard {
    Token mkToken;

    //30 days
    uint256 public planDuration = 2 * 24 * 60 * 60;
    //180 days
    uint256 public _planExpired = 4 * 24 * 60 * 60;

    //30%
    uint8 public interestRate = 30;
    uint256 public planExpired;
    uint8 public totalStaker;

    struct StakeInfo {
        uint256 start;
        uint256 end;
        uint256 amount;
        uint256 claimed;
    }

    event Staked(address indexed from, uint256 amount);
    event Claimed(address indexed from, uint256 amount);

    mapping(address => StakeInfo) public stakeInfos;
    mapping(address => bool) public addressStaked;

    //contructor
    constructor(Token _tokenAddress) {
        require(
            address(_tokenAddress) != address(0),
            "Token address can not be address 0"
        );
        mkToken = _tokenAddress;
        planExpired = block.timestamp + _planExpired;
        totalStaker = 0;
    }

    //transfer token from owner to a address which stakes this token
    function recieveTokenPool(uint256 _amount) external onlyOwner {
        mkToken.transferFrom(_msgSender(), address(this), _amount);
    }

    //start staking by pass amount of token as parameter
    function Stake(uint256 stakeAmount) external {
        require(stakeAmount > 0, "amount of token must be greater than 0");
        require(block.timestamp < planExpired, "Plan expired");
        require(
            addressStaked[_msgSender()] == false,
            "You already participated"
        );
        require(
            mkToken.balanceOf(_msgSender()) > stakeAmount,
            "Token in your wallet is not enough to stake"
        );

        mkToken.transferFrom(address(_msgSender()), address(this), stakeAmount);
        totalStaker++;
        addressStaked[_msgSender()] = true;

        stakeInfos[_msgSender()] = StakeInfo({
            start: block.timestamp,
            end: block.timestamp + planDuration,
            amount: stakeAmount,
            claimed: 0
        });

        emit Staked(_msgSender(), stakeAmount);
    }

    //get reward after staking to be done
    function claimReward() external returns (bool) {
        require(
            addressStaked[_msgSender()] == true,
            "You are not participated"
        );
        require(
            block.timestamp > stakeInfos[_msgSender()].end,
            "Stake time is not over yet"
        );
        require(stakeInfos[_msgSender()].claimed == 0, "You already claimed");

        uint256 stakeAmount = stakeInfos[_msgSender()].claimed;
        uint256 totalAmountRecieved = stakeAmount +
            stakeAmount *
            (interestRate / 100);

        mkToken.transfer(_msgSender(), totalAmountRecieved);

        emit Claimed(_msgSender(), stakeInfos[_msgSender()].claimed);

        return true;
    }

    //get expiry of token
    function getTokenExpiry() external view returns (uint256) {
        require(addressStaked[_msgSender()] == true, "You're not participated");
        return stakeInfos[_msgSender()].end;
    }

    //get amount of token on this contract
    function getAmountToken() external view returns (uint256) {
        return mkToken.balanceOf(address(this));
    }
}
