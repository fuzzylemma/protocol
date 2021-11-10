// SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;


interface IDistributor {
    function distribute() external returns ( bool );
}

interface IMemo {
    function rebase( uint256 ohmProfit_, uint epoch_) external returns (uint256);

    function circulatingSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function gonsForBalance( uint amount ) external view returns ( uint );

    function balanceForGons( uint gons ) external view returns ( uint );
    
    function index() external view returns ( uint );
}


interface IWarmup {
    function retrieve( address staker_, uint amount_ ) external;
}

interface ITimeStaking {
    function unstake(uint256 _amount, bool _trigger) external; 
}