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
    
    function rebase() external; 
}

interface ITreasury {
    function deposit( uint _amount, address _token, uint _profit ) external returns ( bool );
    function valueOf( address _token, uint _amount ) external view returns ( uint value_ );
    function mintRewards( address _recipient, uint _amount ) external;
}


enum PARAMETER { VESTING, PAYOUT, DEBT, MINPRICE }

interface ITimeBondDepository {
    function initializeBondTerms(uint _controlVariable, uint _minimumPrice, uint _maxPayout, uint _maxDebt, uint _initialDebt, uint32 _vestingTerm) external;

    function setBondTerms ( PARAMETER _parameter, uint _input ) external; 

    function setAdjustment ( bool _addition, uint _increment, uint _target, uint32 _buffer ) external; 

    function setStaking( address _staking, bool _helper ) external; 
    
    function deposit( uint _amount, uint _maxPrice, address _depositor) external payable returns ( uint );

    function redeem( address _recipient, bool _stake ) external returns ( uint );

    function stakeOrSend( address _recipient, bool _stake, uint _amount ) external returns ( uint );

}

interface ITimeTreasury {
    function deposit( uint _amount, address _token, uint _profit ) external returns ( uint send_ ); 
    
    function withdraw( uint _amount, address _token ) external; 

    function mintRewards( address _recipient, uint _amount ) external; 

    function valueOf( address _token, uint _amount ) external view returns ( uint value_ ); 
   
}