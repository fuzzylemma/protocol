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

enum CONTRACTS { DISTRIBUTOR, WARMUP, LOCKER }

interface ITimeStaking {
    function stake(uint _amount, address _recipient) external view returns ( bool ); 

    function claim(address _recipient) external; 

    function index() external view returns ( uint ); 

    function unstake(uint256 _amount, bool _trigger) external; 

    function contractBalance() external view returns ( uint );

    function forfeit() external; 

    function giveLockBonus( uint _amount) external; 

    function returnLockBonus(uint _amount) external;

    function toggleDepositLock() external;

    function setWarmup( uint _warmupPeriod) external; 

    function setContract( CONTRACTS _contract, address _address ) external; 

   
}