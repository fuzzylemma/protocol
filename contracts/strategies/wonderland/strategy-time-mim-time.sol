// SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;

import "../strategy-time-farm.sol";

contract StrategyTimeMimTimeLp is TimeFarm {

    // want/lp token for depositing into depositLP for minting Time
    address public mim_time_lp = 0x113f413371fC4CC4C9d6416cf1DE9dFd7BF747Df;
    address public mimTimeBond = 0xA184AE1A71EcAD20E822cB965b99c287590c4FFe;
    address public mim = 0x130966628846BFd36ff31a822705796e8cb8C18D;


    constructor(
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    )
        public
        TimeFarm(
            mimTimeBond,
            mim_time_lp,
            _governance,
            _strategist,
            _controller,
            _timelock
        )
    {}

    // Deposit bond (lp or other token) so that we can get mint Time at a discount and autostake
    function deposit() public override {
        uint256 _mim = IERC20(mim).balanceOf(address(this));
        uint256 _time = IERC20(time).balanceOf(address(this));

        if (_mim > 0 && _time > 0){
            IERC20(mim).safeApprove(joeRouter, 0);
            IERC20(mim).safeApprove(joeRouter, _mim);

            IERC20(time).safeApprove(joeRouter, 0);
            IERC20(time).safeApprove(joeRouter, _time);

            // Adds in liquidity for TIME/MIM
            IJoeRouter(joeRouter).addLiquidity(
                mim,
                time,
                _mim,
                _time,
                0,
                0, 
                address(this), 
                now + 60
            );
        }

        uint256 _amount = IERC20(want).balanceOf(address(this));

        IERC20(mim_time_lp).safeApprove(mimTimeBond, 0);
        IERC20(mim_time_lp).safeApprove(mimTimeBond, _amount);

        ITimeBondDepository(mimTimeBond).deposit(_amount, maxPrice, address(this));
        ITimeBondDepository(mimTimeBond).redeem(address(this), _stake);

        _initialMemo = IERC20(memo).balanceOf(address(this));
    }

    // **** Views ****

    function getName() external pure override returns (string memory) {
        return "StrategyTimeMimTimeLp";
    }
}
