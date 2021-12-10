// SPDX-License-Identifier: MIT	
pragma solidity ^0.6.7;

import "./strategy-wonderland-base.sol";

abstract contract TimeFarm is TimeBase{
    uint256 public _initialMemo; 
    address public bond;

    uint256 public _initial;        // initial amount of memories/time for harvesting later 

    constructor( 
        address _bond,
        address _want,
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    ) 
        public 
        TimeBase(_want, _governance, _strategist, _controller, _timelock)
    {
        bond = _bond;
    }

    function balanceOfPool() public view override returns (uint256) {
        uint256 amount = IMemo(memo).balanceOf(address(this));
        return amount; 
    }

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

   
    function harvest() public override onlyBenevolent {
        ITimeStaking(staking).rebase();  

        uint256 _rebaseMemo = IERC20(memo).balanceOf(address(this));
        uint _amount = _rebaseMemo.sub(_initialMemo);

        if (_amount > 0) {
            // 10% locked up for future governance
            uint256 _keep = _amount.mul(keep).div(keepMax);
            if (_keep > 0) {
                _takeFeeTimeToSnob(_keep);
            }
        }
    }

    function _withdrawSome(uint256 _amount) internal override returns (uint256) {
        IERC20(memo).safeApprove(staking, 0);
        IERC20(memo).safeApprove(staking, _amount);
        ITimeStaking(staking).unstake(_amount, true); 

        return _amount;
    }

}