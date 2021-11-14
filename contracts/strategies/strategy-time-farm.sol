// SPDX-License-Identifier: MIT	
pragma solidity ^0.6.7;

import "./strategy-wonderland-base.sol";

abstract contract StrategyTimeFarm is TimeBase{

    address public rewards; 
    uint256 public _initial; 

    constructor( 
        address _rewards, 
        // uint32 _epochLength,
        // uint _firstEpochNumber,
        // uint32 _firstEpochTime
        
        address _wantToken,
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    ) 
        public 
        TimeBase(_wantToken, _governance, _strategist, _controller, _timelock)
    {
        rewards = _rewards;
    }

    function balanceBeingStaked() public override view returns (uint256){
        //return ITimeStaking(rewards).contractBalance()
        //return IMemo(rewards).balanceOf(address(this))
    }

     // **** State Mutations ****

    function _takeFeeTimeToSnob(uint256 _keep) internal {
        address[] memory path = new address[](3);
        path[0] = Time;
        path[1] = wavax;
        path[2] = snob;
        IERC20(Time).safeApprove(joeRouter, 0);
        IERC20(Time).safeApprove(joeRouter, _keep);
        _swapTraderJoeWithPath(path, _keep);
        uint256 _snob = IERC20(snob).balanceOf(address(this));
        uint256 _share = _snob.mul(revenueShare).div(revenueShareMax);
        IERC20(snob).safeTransfer(feeDistributor, _share);
        IERC20(snob).safeTransfer(
            IController(controller).treasury(),
            _snob.sub(_share)
        );
    }

    // stakes the Time Token 
    function deposit () public override {
        // the amount of Time tokens that you want to stake
        _initial = IERC20(Time).balanceOf(address(this));
        if (_initial > 0){
            IERC20(wantToken).safeApprove(rewards, 0);
            IERC20(wantToken).safeApprove(rewards, _initial);
            ITimeStaking(rewards).stake(_initial, address(this)); 
        }
    }


    //  function _withdrawSome(uint256 _amount) internal override returns (uint256) {
    //     ITimeStaking(rewards).withdraw(_amount);
    //     return _amount;
    // }

    function harvest() public override onlyBenevolent {
        uint256 _amount;

        /**
        call the unstake function that rebases to get the right proportion of the treasury balancer, 
        i.e. determine the amount of MEMOries tokens accumulated during vesting period. 
        As well transfers MEMOries token to Time tokens
        */

        // Collect the time tokens
        ITimeStaking(Memories).unstake(_amount, true);
        uint256 _time = IERC20(Time).balanceOf( address(this));

        //Determine the delta value of the accumulated TIME and OG TIME after each epoch
        uint256 deltaTime = _initial.sub(_time); 

        //take 10% of that fee and invest it into our snowglobe 
        if (deltaTime > 0){
            uint256 _keep = deltaTime.mul(keep).div(keepMax);
                _takeFeeTimeToSnob(_keep);
        }


    }




}