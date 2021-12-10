// SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;

import "../strategy-time-farm.sol";

abstract contract StrategyTimeMim is TimeFarm {

    // want token for depositing into depositLP for minting Time
    address public mim = 0x130966628846BFd36ff31a822705796e8cb8C18D;
    address public mimBond = 0x694738E0A438d90487b4a549b201142c1a97B556;


    constructor(
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    )
        public
        TimeFarm(
            mimBond,
            mim,
            _governance,
            _strategist,
            _controller,
            _timelock
        )
    {}

     // Deposit bond (lp or other token) so that we can get mint Time at a discount and autostake
    function depositBond() public override {
        uint256 _amount = IERC20(want).balanceOf(address(this));

        IERC20(want).safeApprove(mimBond, 0); 
        IERC20(want).safeApprove(mimBond, _amount); 

        ITimeBondDepository(mimBond).deposit(_amount, maxPrice, address(this));     // deposit mim for time tokens
        ITimeBondDepository(mimBond).redeem(address(this), _stake);                 // stake time tokens

        _initialMemo = IERC20(memo).balanceOf(address(this));
    }

    // **** Views ****

    function getName() external pure override returns (string memory) {
        return "StrategyTimeMim";
    }
}
