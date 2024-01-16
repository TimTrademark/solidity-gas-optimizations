// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "../interfaces/IUniswapV2Pair.sol";
import "../interfaces/IERC20.sol";

contract OptimizedMultiHopSwapContract {
    struct Trade {
        address pair;
        address token0;
    }

    function executeSwaps(Trade[] calldata trades, uint amountIn) external {
        //send tokens to first pair
        IERC20(trades[0].token0).transfer(trades[0].pair, amountIn);
        //cache variable needed during trades
        uint lastOut;
        for (
            uint i;
            i < trades.length;
            i = uncheckedIncrement(i) //use unchecked increment to save gas
        ) {
            Trade memory current = trades[i];
            address recipient = i == trades.length - 1
                ? address(this)
                : trades[i + 1].pair;
            uint amount = i == 0 ? amountIn : lastOut;
            lastOut = executeUniswapV2Trade(
                current.pair,
                current.token0,
                recipient,
                amount
            );
        }
    }

    function executeUniswapV2Trade(
        address pair,
        address token0,
        address recipient,
        uint amountIn
    ) private returns (uint amountOut) {
        //get reserves
        (uint reserve0, uint reserve1, ) = IUniswapV2Pair(pair).getReserves();
        (uint reserveA, uint reserveB) = IUniswapV2Pair(pair).token0() == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
        //calculate amountOut for swap
        amountOut = getAmountOut(amountIn, reserveA, reserveB);
        (uint amountOut0, uint amountOut1) = IUniswapV2Pair(pair).token0() ==
            token0
            ? (uint(0), amountOut)
            : (amountOut, uint(0));
        //swap without transferring tokens (this has already been done by the previous pair)
        IUniswapV2Pair(pair).swap(
            amountOut0,
            amountOut1,
            recipient,
            new bytes(0)
        );
    }

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) internal pure returns (uint amountOut) {
        require(amountIn > 0, "INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "INSUFFICIENT_LIQUIDITY");
        uint amountInWithFee = amountIn * 997;
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = (reserveIn * 1000) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    //unchecked increment saves even more gas
    function uncheckedIncrement(uint i) private pure returns (uint) {
        unchecked {
            return ++i;
        }
    }
}
