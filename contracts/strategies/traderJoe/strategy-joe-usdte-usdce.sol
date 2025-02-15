// SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;

import "../strategy-joe-farm-base.sol";

contract StrategyJoeUsdtEUsdcELp is StrategyJoeFarmBase {
    uint256 public avax_joe_poolId = 49;

    address public joe_usdte_usdce_lp =
        0x2E02539203256c83c7a9F6fA6f8608A32A2b1Ca2;
    address public usdte = 0xc7198437980c041c805A1EDcbA50c1Ce5db95118;
    address public usdce = 0xA7D7079b0FEaD91F3e65f86E8915Cb59c1a4C664;

    constructor(
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    )
        public
        StrategyJoeFarmBase(
            avax_joe_poolId,
            joe_usdte_usdce_lp,
            _governance,
            _strategist,
            _controller,
            _timelock
        )
    {}

    // **** State Mutations ****

    function harvest() public override onlyBenevolent {
        // Anyone can harvest it at any given time.
        // I understand the possibility of being frontrun
        // But AVAX is a dark forest, and I wanna see how this plays out
        // i.e. will be be heavily frontrunned?
        //      if so, a new strategy will be deployed.

        // Collects Joe tokens
        IMasterChefJoeV2(masterChefJoeV2).deposit(poolId, 0);

        uint256 _joe = IERC20(joe).balanceOf(address(this));
        if (_joe > 0) {
            // 10% is sent to treasury
            uint256 _keep = _joe.mul(keep).div(keepMax);
            uint256 _amount = _joe.sub(_keep).div(2);
            if (_keep > 0) {
                _takeFeeJoeToSnob(_keep);
            }
            IERC20(joe).safeApprove(joeRouter, 0);
            IERC20(joe).safeApprove(joeRouter, _joe.sub(_keep));

            _swapTraderJoe(joe, usdte, _amount);
            _swapTraderJoe(joe, usdce, _amount);
        }

        // Adds in liquidity for USDT.e/WBTC.e
        uint256 _usdte = IERC20(usdte).balanceOf(address(this));
        uint256 _usdce = IERC20(usdce).balanceOf(address(this));

        if (_usdte > 0 && _joe > 0) {
            IERC20(usdte).safeApprove(joeRouter, 0);
            IERC20(usdte).safeApprove(joeRouter, _usdte);

            IERC20(usdce).safeApprove(joeRouter, 0);
            IERC20(usdce).safeApprove(joeRouter, _usdce);

            IJoeRouter(joeRouter).addLiquidity(
                usdte,
                usdce,
                _usdte,
                _usdce,
                0,
                0,
                address(this),
                now + 60
            );

            // Donates DUST
            IERC20(usdte).transfer(
                IController(controller).treasury(),
                IERC20(usdte).balanceOf(address(this))
            );
            IERC20(usdce).safeTransfer(
                IController(controller).treasury(),
                IERC20(usdce).balanceOf(address(this))
            );
        }

        _distributePerformanceFeesAndDeposit();
    }

    // **** Views ****

    function getName() external pure override returns (string memory) {
        return "StrategyJoeUsdtEUsdcELp";
    }
}
