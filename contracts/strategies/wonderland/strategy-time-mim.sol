// SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;

import "../strategy-time-farm.sol";

abstract contract StrategyTimeMim is TimeFarm {

    // want token for depositing into depositLP for minting Time
    address public mim = 0x130966628846BFd36ff31a822705796e8cb8C18D;


    constructor(
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    )
        public
        TimeFarm(
            staking, 
            mim,
            _governance,
            _strategist,
            _controller,
            _timelock
        )
    {}
    

    // **** Views ****

    function getName() external pure override returns (string memory) {
        return "StrategyTimeMim";
    }
}
