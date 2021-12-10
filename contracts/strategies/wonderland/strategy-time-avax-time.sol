// SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;

import "../strategy-time-farm.sol";

abstract contract StrategyTimeAvaxTime is TimeFarm {

    // want/lp token for depositing into depositLP for minting Time
    address public avax_time_lp = 0xf64e1c5B6E17031f5504481Ac8145F4c3eab4917;
    address public avaxTimeBond = 0xc26850686ce755FFb8690EA156E5A6cf03DcBDE1;


    constructor(
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    )
        public
        TimeFarm(
            avaxTimeBond,
            avax_time_lp,
            _governance,
            _strategist,
            _controller,
            _timelock
        )
    {}

    // Deposit bond (lp or other token) so that we can get mint Time at a discount and autostake
    function depositBond() public override {
        // Wrap the avax     
        uint256 _avax = address(this).balance;              
        if (_avax > 0) {                               
            WAVAX(wavax).deposit{value: _avax}();
        }

        uint256 _wavax = IERC20(wavax).balanceOf(address(this));
        uint256 _time = IERC20(time).balanceOf(address(this));

        if (_wavax > 0 && _time > 0){
            IERC20(wavax).safeApprove(joeRouter, 0);
            IERC20(wavax).safeApprove(joeRouter, _wavax);

            IERC20(time).safeApprove(joeRouter, 0);
            IERC20(time).safeApprove(joeRouter, _time);

            // Adds in liquidity for TIME/AVAX
            IJoeRouter(joeRouter).addLiquidity(
                wavax,
                time,
                _wavax,
                _time,
                0,
                0, 
                address(this), 
                now + 60
            );
        }

        uint256 _amount = IERC20(want).balanceOf(address(this));

        IJoePair(avax_time_lp).approve(avaxTimeBond, _amount);

        ITimeBondDepository(avaxTimeBond).deposit(_amount, maxPrice, address(this));
        ITimeBondDepository(avaxTimeBond).redeem(address(this), _stake);

        _initialMemo = IERC20(memo).balanceOf(address(this));
    }

    // **** Views ****

    function getName() external pure override returns (string memory) {
        return "StrategyTimeAvaxTime";
    }
}
