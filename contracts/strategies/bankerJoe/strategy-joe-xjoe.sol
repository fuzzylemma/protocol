// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../strategy-bankerjoe-farm-base.sol";

contract StrategyJoeXJoe is StrategyBankerJoeFarmBase {
    address public constant xJoe = 0x57319d41F71E81F3c65F2a47CA4e001EbAFd4F33; //banker joe deposit token
    address public constant jXJOE = 0xC146783a59807154F92084f9243eb139D58Da696; //lending receipt token

    constructor(
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    )
        public
        StrategyBankerJoeFarmBase(
            xJoe, 
            jXJOE, 
            _governance, 
            _strategist, 
            _controller, 
            _timelock
        )
    {}

    function deposit() public override {
        uint256 _want = IERC20(want).balanceOf(address(this));
        if (_want > 0) {
            IERC20(want).safeApprove(jToken, 0);
            IERC20(want).safeApprove(jToken, _want);
            require(IJToken(jToken).mint(_want) == 0, "!deposit");
        }
    }

    function _withdrawSome(uint256 _amount)
        internal
        override
        returns (uint256)
    {
        uint256 _want = balanceOfWant();
        
        if (_want < _amount) {
            uint256 _redeem = _amount.sub(_want);
            // Make sure market can cover liquidity
            require(IJToken(jToken).getCash() >= _redeem, "!cash-liquidity");
            // How much borrowed amount do we need to free?
            uint256 borrowed = getBorrowed();
            uint256 supplied = getSupplied();
            uint256 curLeverage = getCurrentLeverage();
            uint256 borrowedToBeFree = _redeem.mul(curLeverage).div(1e18);
            // If the amount we need to free is > borrowed
            // Just free up all the borrowed amount
            if (borrowed > 0) {
                if (borrowedToBeFree > borrowed) {
                    this.deleverageToMin();
                } else {
                    // Just keep freeing up borrowed amounts until
                    // we hit a safe number to redeem our underlying
                    this.deleverageUntil(supplied.sub(borrowedToBeFree));
                }
            }
            // Redeems underlying
            require(IJToken(jToken).redeemUnderlying(_redeem) == 0, "!redeem");
        }
        return _amount;
    }

    // **** Views **** //

    function getName() external override pure returns (string memory) {
        return "StrategyJoeXJoe";
    }
}