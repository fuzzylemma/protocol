// SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;

import "../strategy-time-farm.sol";

abstract contract StrategyTimeXTimeLp is TimeFarm {

    constructor(
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    )
        public
        TimeFarm(
            bond,
            time,
            _governance,
            _strategist,
            _controller,
            _timelock
        )
    {}

    // Deposits the Time token in the staking contract 
    function deposit () public override {
        // the amount of Time tokens that you want to stake
        uint256 _amount = IERC20(time).balanceOf(address(this)); 

        if (_amount > 0){
             if ( useHelper ) { // use if staking warmup is 0
                IERC20(time).safeApprove( address(stakingHelper), 0 );
                IERC20(time).safeApprove( address(stakingHelper), _amount );
                IStakingHelper(stakingHelper).stake( _amount, address(this) );
            } else {
                IERC20(time).safeApprove( address(staking), 0 );
                IERC20(time).safeApprove( address(staking), _amount );
                IStaking(staking).stake( _amount, address(this) );
            }
        }
        _initialMemo = IERC20(memo).balanceOf(address(this));
    }
    
    // **** Views ****

    function getName() external pure override returns (string memory) {
        return "StrategyTimeXTimeLp";
    }
}
