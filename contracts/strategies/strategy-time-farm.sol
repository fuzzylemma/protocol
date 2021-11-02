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


function harvest() public override onlyBenevolent {

    
      //check the balance of Time Tokens. 
        uint256 _TIME = IERC20(Time).balanceOf(address(this));
        if (_TIME > 0){
           uint256 _keep = _TIME.mul(keep).div(keepMax);
           if (_keep > 0){
               _takeFeeTimeToSnob(_keep);
           }
        }
}




}