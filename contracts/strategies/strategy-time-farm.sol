// SPDX-License-Identifier: MIT	
pragma solidity ^0.6.7;

import "./strategy-wonderland-base.sol";

abstract contract TimeFarm is TimeBase{

    address public rewards; 
    address public treasury = 0x1c46450211CB2646cc1DA3c5242422967eD9e04c;
    address bondToken; 


    uint profit;
    uint256 public _initial; 

    constructor( 
        address _rewards,
        address _mint,
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    ) 
        public 
        TimeBase(_mint, _governance, _strategist, _controller, _timelock)
    {
        rewards = _rewards; 
    }

    function getHarvestable() external view returns (uint256) {
        return IMemo(Memories).index();
    }


    // Deposits the Time token in the staking contract 
    function deposit () public override {
        // the amount of Time tokens that you want to stake
        uint256 _want = IERC20(Time).balanceOf(address(this));
        if (_want > 0){
            IERC20(Time).safeApprove(rewards, 0);
            IERC20(Time).safeApprove(rewards, _want);
            IStaking(rewards).stake(_want, address(this));
        }
    }

    // Bond deposit so that we can get discounted time minted and staked 
    function depositIntoTime() public override {
        uint256 _amount = IERC20(bondToken).balanceOf(address(this));

        uint256 _profit = ITreasury(treasury).valueOf(bondToken, _amount);
        ITreasury(treasury).deposit(_amount, want, _profit);
     
    }

    /**
        calls the unstake function that rebases to get the right proportion of the treasury balancer, 
        i.e. determine the amount of MEMOries tokens accumulated during vesting period. 
        As well transfers MEMOries token to Time tokens
    */
    function harvest() public override onlyBenevolent {
        
        // find how much we have grown by at a particular epoch period 
        uint256 _amount = IMemo(Memories).index(); 

        if (_amount > 0) {
            // 10% locked up for future governance
            uint256 _keep = _amount.mul(keep).div(keepMax);
            if (_keep > 0) {
                _takeFeeTimeToSnob(_keep);
            }
        }

        // restake or unstake the current value left 
        _amount = IERC20(Memories).balanceOf(address(this));

        bool _stake; 
        stakeOrSend(address(this), _stake, _amount);
    }


}