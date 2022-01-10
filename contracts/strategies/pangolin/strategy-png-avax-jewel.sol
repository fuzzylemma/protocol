pragma solidity ^0.6.7;

import "../strategy-png-minichef-farm-base.sol";

contract StrategyPngAvaxJewel is StrategyPngMiniChefFarmBase {
    uint256 public _poolId = 46;

    // Token addresses
    address public png_avax_jewel_lp = 0x9AA76aE9f804E7a70bA3Fb8395D0042079238E9C;
    address public jewel = 0x4f60a160D8C2DDdaAfe16FCC57566dB84D674BD6;

    constructor(
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    )
        public
        StrategyPngMiniChefFarmBase(
            _poolId,
            png_avax_jewel_lp,
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

        // Swap half WAVAX for JEWEL
        uint256 _wavax = IERC20(wavax).balanceOf(address(this));
        if (_wavax > 0) {
            _swapPangolin(wavax, jewel, _wavax.div(2));
        }

        // Adds in liquidity for AVAX/JEWEL
        _wavax = IERC20(wavax).balanceOf(address(this));
        uint256 _jewel = IERC20(jewel).balanceOf(address(this));

        if (_wavax > 0 && _jewel > 0) {
            IERC20(wavax).safeApprove(pangolinRouter, 0);
            IERC20(wavax).safeApprove(pangolinRouter, _wavax);

            IERC20(jewel).safeApprove(pangolinRouter, 0);
            IERC20(jewel).safeApprove(pangolinRouter, _jewel);

            IPangolinRouter(pangolinRouter).addLiquidity(
                wavax,
                jewel,
                _wavax,
                _jewel,
                0,
                0,
                address(this),
                now + 60
            );

            _wavax = IERC20(wavax).balanceOf(address(this));
            _jewel = IERC20(jewel).balanceOf(address(this));
            
            // Donates DUST
            if (_wavax > 0){
                IERC20(wavax).transfer(
                    IController(controller).treasury(),
                    _wavax
                );
            }
            if (_jewel > 0){
                IERC20(jewel).safeTransfer(
                    IController(controller).treasury(),
                    _jewel
                );
            }
        }

        _distributePerformanceFeesAndDeposit();
    }

    // **** Views ****

    function getName() external pure override returns (string memory) {
        return "StrategyPngAvaxJewel";
    }
}