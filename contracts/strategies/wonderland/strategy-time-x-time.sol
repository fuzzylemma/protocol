// SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;

import "../strategy-time-farm.sol";

abstract contract StrategyTimeXTime is TimeFarm {

    constructor(
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    )
        public
        TimeFarm(
            bond,
            time,
            _governance,
            _strategist,
            _controller,
            _timelock
        )
    {}


    // **** Views ****

    function getName() external pure override returns (string memory) {
        return "StrategyTimeXTime";
    }
}
