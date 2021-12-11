// SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;

import "../strategy-time-farm.sol";

contract StrategyTimeAvaxLp is TimeFarm {

    // want token for depositing into depositLP for minting Time
    address avaxBond = 0xE02B1AA2c4BE73093BE79d763fdFFC0E3cf67318;


    constructor(
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    )
        public
        TimeFarm(
            avaxBond,
            wavax,
            _governance,
            _strategist,
            _controller,
            _timelock
        )
    {}

     // Deposit bond (lp or other token) so that we can get mint Time at a discount and autostake
    function deposit() public override {
        // Wrap the avax     
        uint256 _avax = address(this).balance;              
        if (_avax > 0) {                               
            WAVAX(wavax).deposit{value: _avax}();
        }

        uint256 _amount = IERC20(want).balanceOf(address(this));

        IERC20(want).safeApprove(avaxBond, 0); 
        IERC20(want).safeApprove(avaxBond, _amount); 

        ITimeBondDepository(avaxBond).deposit(_amount, maxPrice, address(this));
        ITimeBondDepository(avaxBond).redeem(address(this), _stake);

        _initialMemo = IERC20(memo).balanceOf(address(this));
    }

    // **** Views ****

    function getName() external pure override returns (string memory) {
        return "StrategyTimeAvaxLp";
    }
}
