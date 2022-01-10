pragma solidity ^0.6.7;

import "../strategy-png-minichef-farm-base.sol";

contract StrategyPngAvaxAvai is StrategyPngMiniChefFarmBase {
    uint256 public _poolId = 44;

    // Token addresses
    address public png_avax_avai_lp = 0x6CbfB991986EbbBc91Bf21CeaA3cBf1BD82469cf;
    address public avai = 0x346A59146b9b4a77100D369a3d18E8007A9F46a6;

    constructor(
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    )
        public
        StrategyPngMiniChefFarmBase(
            _poolId,
            png_avax_avai_lp,
            _governance,
            _strategist,
            _controller,
            _timelock
        )
    {}

    // **** State Mutations ****

    function harvest() public override onlyBenevolent {
        // Collects Png tokens
        IMiniChef(miniChef).harvest(poolId, address(this));

        uint256 _png = IERC20(png).balanceOf(address(this));
        if (_png > 0) {
            // 10% is sent to treasury
            uint256 _keep = _png.mul(keep).div(keepMax);
            if (_keep > 0) {
                _takeFeePngToSnob(_keep);
            }

            _png = IERC20(png).balanceOf(address(this));

            IERC20(png).safeApprove(pangolinRouter, 0);
            IERC20(png).safeApprove(pangolinRouter, _png);

            _swapPangolin(png, wavax, _png);    
        }

        // Swap half WAVAX for AVAI
        uint256 _wavax = IERC20(wavax).balanceOf(address(this));
        if (_wavax > 0) {
            _swapPangolin(wavax, avai, _wavax.div(2));
        }

        // Adds in liquidity for AVAX/AVAI
        _wavax = IERC20(wavax).balanceOf(address(this));
        uint256 _avai = IERC20(avai).balanceOf(address(this));

        if (_wavax > 0 && _avai > 0) {
            IERC20(wavax).safeApprove(pangolinRouter, 0);
            IERC20(wavax).safeApprove(pangolinRouter, _wavax);

            IERC20(avai).safeApprove(pangolinRouter, 0);
            IERC20(avai).safeApprove(pangolinRouter, _avai);

            IPangolinRouter(pangolinRouter).addLiquidity(
                wavax,
                avai,
                _wavax,
                _avai,
                0,
                0,
                address(this),
                now + 60
            );

            _wavax = IERC20(wavax).balanceOf(address(this));
            _avai = IERC20(avai).balanceOf(address(this));
            
            // Donates DUST
            if (_wavax > 0){
                IERC20(wavax).transfer(
                    IController(controller).treasury(),
                    _wavax
                );
            }
            if (_avai > 0){
                IERC20(avai).safeTransfer(
                    IController(controller).treasury(),
                    _avai
                );
            }
        }
        
        _distributePerformanceFeesAndDeposit();
    }

    // **** Views ****

    function getName() external pure override returns (string memory) {
        return "StrategyPngAvaxAvai";
    }
}