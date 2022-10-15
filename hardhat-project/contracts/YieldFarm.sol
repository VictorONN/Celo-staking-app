// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

import "./Token1.sol";
import "./Token2.sol";

contract YieldFarm {

    IERC20 token1;
    IERC20 token2;

    address[] public stakers;

    uint256 public totalStaked;

    uint256 public collateralFactor = 0.7;

    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    constructor (address _token1, address _token2) {
        token1 = IERC20(_token1);
        token2 = IERC20(_token2); 
    }

    function stake(uint256 _amount) public {
        //checks
        require(_amount > 0, "amount cannot be 0");
        //effects
        stakingBalance[msg.sender] += _amount;
        totalStaked = totalStaked + _amount;
        hasStaked[msg.sender] = true; 
        //interactions
        require(token1.transferFrom(msg.sender, address(this), _amount));
    }

    function borrow(uint256 _amount) public {
            //checks
            require(hasStaked[msg.sender], "User has not deposited");
            uint256 userBalance = stakingBalance[msg.sender];
            require(_amount <= userBalance * collateralFactor, "Wrong amounts");
            //effects
            totalStaked = totalStaked - _amount;
            uint256 newBalance = stakingBalance[msg.sender] - _amount; 
            stakingBalance[msg.sender] = newBalance;
            //interactions
            require(token1.transfer(msg.sender, _amount));    
        }

            function withdraw(uint256 _amount) public {
        //checks
        require(hasStaked[msg.sender], "User has not deposited");
        uint256 userBalance = stakingBalance[msg.sender];
        require(userBalance >= _amount, "Wrong amounts");
        //effects
        totalStaked = totalStaked - _amount;
        uint256 newBalance = stakingBalance[msg.sender] - _amount; 
        stakingBalance[msg.sender] = newBalance;
        //interactions
        require(token1.transfer(msg.sender, _amount));
        require(token2.transfer(msg.sender, _amount));    
    }

}

