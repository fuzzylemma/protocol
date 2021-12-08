// SPDX-License-Identifier: MIT	
pragma solidity ^0.6.7;

import "./strategy-wonderland-base.sol";

abstract contract TimeFarm is TimeBase{

    address public rewards; 
    address public treasury = 0x1c46450211CB2646cc1DA3c5242422967eD9e04c;


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

    function balanceOfTime() public override view returns (uint256){
        return ITimeStaking(Time).contractBalance(); 
    }

    function getHarvestable() external view returns (uint256) {
        return ITimeStaking(Time).index();
    }


    // Deposits the Time token in the staking contract 
    function deposit () public override {
        // the amount of Time tokens that you want to stake
        uint256 _want = IERC20(Time).balanceOf(address(this));
        if (_want > 0){
            IERC20(Time).safeApprove(rewards, 0);
            IERC20(Time).safeApprove(rewards, _want);
            ITimeStaking(rewards).stake(_want, address(this)); 
        }
    }

    // Stakes Time payout in the automatically or returns to the user if they do not want to continue staking
    function stakeOrSend ( address _recipient, bool _stake, uint _amount) public override returns (uint256) {
        uint256 _want = IERC20(Time).balanceOf(address(this));
        // if user does not want to stake 
        if (!_stake) {
            IERC20(Time).transfer( _recipient, _amount );       // send payout
        }else {                                                 // if user wants to stake
            if (useHelper) {                                    // if stake warmup is 0
                IERC20(Time).approve(stakingHelper, _want);
                IStakingHelper(stakingHelper).stake(_want, _recipient);
            }else {
                IERC20(Time).approve(rewards, _want);
                IStaking(rewards).stake( _want, _recipient );
            }
        }

        return _want; 
    }
   


    // Deposits other asset to be minted into Time and then staked 
    function depositIntoTime() public override {
        uint256 _amount = IERC20(want).balanceOf(address(this));
        ITimeTreasury(treasury).deposit(_amount, want, profit);
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

        _distributePerformanceFeesAndDeposit();
    }




}