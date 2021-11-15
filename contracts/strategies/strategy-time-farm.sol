// SPDX-License-Identifier: MIT	
pragma solidity ^0.6.7;

import "./strategy-wonderland-base.sol";

abstract contract StrategyTimeFarm is TimeBase{

    address public rewards = 0x4456B87Af11e87E329AB7d7C7A246ed1aC2168B9; 
    uint256 public _initial; 

    constructor( 
        address _rewards, 
        address _wantToken,
        address _governance,
        address _strategist,
        address _controller,
        address _timelock,
        uint32 _epochLength,
        uint _firstEpochNumber,
        uint32 _firstEpochTime
    ) 
        public 
        TimeBase(_wantToken, _governance, _strategist, _controller, _timelock, _epochLength, _firstEpochNumber, _firstEpochTime)
    {
        rewards = _rewards;

        
    }

    function balanceOfTime() public override view returns (uint256){
        return ITimeStaking(Time).contractBalance(); 
    }

    function getHarvestable() external view returns (uint256) {
        return ITimeStaking(Time).index();
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

    // deposits the Time token in the staking contract 
    function deposit () public override {
        // the amount of Time tokens that you want to stake
        _initial = IERC20(Time).balanceOf(address(this));
        if (_initial > 0){
            IERC20(wantToken).safeApprove(rewards, 0);
            IERC20(wantToken).safeApprove(rewards, _initial);
            ITimeStaking(rewards).stake(_initial, address(this)); 
        }
    }


    /**
        @notice we have to restake time tokens whenever the epoch is over
    */
    function reStake() public override {
        ITimeStaking(Time).rebase(); 
        deposit(); 
    }


    /**
        calls the unstake function that rebases to get the right proportion of the treasury balancer, 
        i.e. determine the amount of MEMOries tokens accumulated during vesting period. 
        As well transfers MEMOries token to Time tokens
    */
    function harvest() public override onlyBenevolent {

        uint256 _amount = ITimeStaking(Time).index(); 

        if (_amount > 0) {
            // 10% locked up for future governance
            uint256 _keep = _amount.mul(keep).div(keepMax);
            if (_keep > 0) {
                _takeFeeTimeToSnob(_keep);
            }
        }
        // Collect the time tokens
        ITimeStaking(Time).unstake(_amount, true);
    

    }




}