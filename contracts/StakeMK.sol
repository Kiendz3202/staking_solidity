// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

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

contract StakeMK is Pausable, Ownable, ReentrancyGuard {
    Token mkToken;

    // 30 Days (30 * 24 * 60 * 60)
    uint256 public planDuration = 2592000;

    // 180 Days (180 * 24 * 60 * 60)
    uint256 _planExpired = 15552000;

    uint8 public interestRate = 30;
    uint256 public planExpired;
    uint8 public totalStakers;

    struct StakeInfo {
        uint256 startTS;
        uint256 endTS;
        uint256 amount;
        uint256 claimed;
    }

    event Staked(address indexed from, uint256 amount);
    event Claimed(address indexed from, uint256 amount);

    mapping(address => StakeInfo) public stakeInfos;
    mapping(address => bool) public addressStaked;

    constructor(Token _tokenAddress) {
        require(
            address(_tokenAddress) != address(0),
            "Token Address cannot be address 0"
        );
        mkToken = _tokenAddress;
        planExpired = block.timestamp + planDuration;
        totalStakers = 0;
    }

    function transferToken(address to, uint256 amount) external onlyOwner {
        require(mkToken.transfer(to, amount), "Token transfer failed!");
    }

    function claimReward() external returns (bool) {
        require(
            addressStaked[_msgSender()] == true,
            "You are not participated"
        );
        require(
            stakeInfos[_msgSender()].endTS < block.timestamp,
            "Stake Time is not over yet"
        );
        require(stakeInfos[_msgSender()].claimed == 0, "Already claimed");

        uint256 stakeAmount = stakeInfos[_msgSender()].amount;
        uint256 totalTokens = stakeAmount +
            ((stakeAmount * interestRate) / 100);
        stakeInfos[_msgSender()].claimed == totalTokens;
        mkToken.transfer(_msgSender(), totalTokens);

        emit Claimed(_msgSender(), totalTokens);

        return true;
    }

    function getTokenExpiry() external view returns (uint256) {
        require(
            addressStaked[_msgSender()] == true,
            "You are not participated"
        );
        return stakeInfos[_msgSender()].endTS;
    }

    function stakeToken(uint256 stakeAmount) external whenNotPaused {
        require(stakeAmount > 0, "Stake amount should be correct");
        require(block.timestamp < planExpired, "Plan Expired");
        require(
            addressStaked[_msgSender()] == false,
            "You already participated"
        );
        require(
            mkToken.balanceOf(_msgSender()) >= stakeAmount,
            "Insufficient Balance"
        );

        mkToken.transferFrom(_msgSender(), address(this), stakeAmount);
        totalStakers++;
        addressStaked[_msgSender()] = true;

        stakeInfos[_msgSender()] = StakeInfo({
            startTS: block.timestamp,
            endTS: block.timestamp + planDuration,
            amount: stakeAmount,
            claimed: 0
        });

        emit Staked(_msgSender(), stakeAmount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}

// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/security/Pausable.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/utils/Context.sol";

// interface Token {
//     function transfer(address recipient, uint256 amount)
//         external
//         returns (bool);

//     function balanceOf(address account) external view returns (uint256);

//     function transferFrom(
//         address sender,
//         address recipient,
//         uint256 amount
//     ) external returns (uint256);
// }

// contract StakeMK is Ownable, ReentrancyGuard {
//     Token mkToken;

//     //30 days
//     uint256 public planDuration;
//     //180 days
//     // uint256 public _planExpired = 15552000;

//     //30%
//     uint8 public interestRate;
//     // uint256 public planExpired;
//     uint8 public totalStaker;

//     struct StakeInfo {
//         uint256 start;
//         uint256 end;
//         uint256 amount;
//         uint256 claimed;
//     }

//     event Staked(address indexed from, uint256 amount);
//     event Claimed(address indexed from, uint256 amount);

//     mapping(address => StakeInfo) public stakeInfos;
//     mapping(address => bool) public addressStaked;

//     //contructor
//     constructor(Token _tokenAddress) {
//         require(
//             address(_tokenAddress) != address(0),
//             "Token address can not be address 0"
//         );
//         mkToken = _tokenAddress;
//         planDuration = 2592000;
//         interestRate = 30;
//         totalStaker = 0;
//     }

//     function transferToken(address to, uint256 amount) external onlyOwner {
//         require(mkToken.transfer(to, amount), "Token transfer failed!");
//     }

//     //start staking by pass amount of token as parameter
//     function Stake(uint256 stakeAmount) external {
//         require(stakeAmount > 0, "amount of token must be greater than 0");
//         require(
//             addressStaked[_msgSender()] == false,
//             "You already participated"
//         );
//         require(
//             mkToken.balanceOf(_msgSender()) >= stakeAmount,
//             "Token in your wallet is not enough to stake"
//         );

//         mkToken.transferFrom(_msgSender(), address(this), stakeAmount);
//         totalStaker++;
//         addressStaked[_msgSender()] = true;

//         stakeInfos[_msgSender()] = StakeInfo({
//             start: block.timestamp,
//             end: block.timestamp + planDuration,
//             amount: stakeAmount,
//             claimed: 0
//         });

//         emit Staked(_msgSender(), stakeAmount);
//     }

//     //get reward after staking to be done
//     function claimReward() external {
//         require(
//             addressStaked[_msgSender()] == true,
//             "You are not participated"
//         );
//         require(
//             block.timestamp > stakeInfos[_msgSender()].end,
//             "Stake time is not over yet"
//         );
//         require(stakeInfos[_msgSender()].claimed == 0, "You already claimed");

//         uint256 stakeAmount = stakeInfos[_msgSender()].amount;
//         uint256 totalTokens = stakeAmount +
//             ((stakeAmount * interestRate) / 100);

//         stakeInfos[_msgSender()].claimed == totalTokens;

//         mkToken.transfer(_msgSender(), totalTokens);

//         emit Claimed(_msgSender(), stakeInfos[_msgSender()].claimed);
//     }

//     //get expiry of token
//     function getTokenExpiry() external view returns (uint256) {
//         require(addressStaked[_msgSender()] == true, "You're not participated");
//         return stakeInfos[_msgSender()].end;
//     }

//     //get amount of token on this contract
//     function getAmountToken() external view returns (uint256) {
//         return mkToken.balanceOf(address(this));
//     }
// }
