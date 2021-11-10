// SPDX-License-Identifier: MIT	
pragma solidity ^0.6.7;

import "./strategy-time-stake.sol";

abstract contract StrategyTimeFarm is TimeStaking{

    constructor( 
        address _Time, 
        address _Memories, 
        uint32 _epochLength,
        uint _firstEpochNumber,
        uint32 _firstEpochTime
    ) public{}

     // **** State Mutations ****

    function _takeFeeTimeToSnob(uint256 _keep) internal {
        address[] memory path = new address[](3);
        path[0] = Time;
        path[1] = wavax;
        path[2] = snob;
        IERC20(Time).safeApprove(pangolinRouter, 0);
        IERC20(Time).safeApprove(pangolinRouter, _keep);
        _swapPangolinWithPath(path, _keep);
        uint256 _snob = IERC20(snob).balanceOf(address(this));
        uint256 _share = _snob.mul(revenueShare).div(revenueShareMax);
        IERC20(snob).safeTransfer(feeDistributor, _share);
        IERC20(snob).safeTransfer(
            IController(controller).treasury(),
            _snob.sub(_share)
        );
    }


function deposit () public override {
    uint256 _want = IERC20(Time).balanceOf(address(this));
    if (_want > 0){
        IERC20(Time).safeApprove(Time, 0);
        IERC20(Time).safeApprove(Time, _want);
        //ITimeStaking(Time).stake( _want, address(this)); 

    }
}

function harvest() public override onlyBenevolent {

    //find before getting to harvest because all of it has been
    //get the original balance of the Time tokens
    uint256 _time = IERC20(Time).balanceOf( address(this));

    /**
     call the unstake function that rebases to get the right proportion of the treasury balancer, 
     i.e. determine the amount of MEMOries tokens accumulated during vesting period. 
     As well transfers MEMOries token to Time tokens
     */

     //depends on the contract!!!!!!!!
    ITimeStaking(Memories).unstake(_time, true);


    uint256 _afterTime = IERC20(Time).balanceOf( address(this));

    //Determine the delta value of the accumulated TIME and OG TIME after each epoch
    uint256 deltaTime = _afterTime.sub(_time); 

    //take 10% of that fee and invest it into our snowglobe 


        uint256 _TIME = IERC20(Time).balanceOf(address(this));
        if (deltaTime > 0){
           uint256 _keep = deltaTime.mul(keep).div(keepMax);
               _takeFeeTimeToSnob(_keep);
            
        }
}




}