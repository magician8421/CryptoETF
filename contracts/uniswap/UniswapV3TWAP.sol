// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "uniswap-v3-periphery-0.8/contracts/libraries/OracleLibrary.sol";
import "hardhat/console.sol";

contract UniswapV3TWAP{

    address public immutable uniswapV3Factory;

    constructor(address _factory){
         uniswapV3Factory=_factory;
    }   
    function estimateAmountOut(
        address tokenIn,
        address tokenOut,
        uint128 amountIn,
        uint32 secondsAgo
    )  external view returns (uint amountOut) {
        (address token0, address token1) = tokenIn < tokenOut ? (tokenIn, tokenOut) : (tokenOut, tokenIn);
        address _pool=IUniswapV3Factory(uniswapV3Factory).getPool(token0,token1,3000);
        (int24 tick,)  =OracleLibrary.consult(_pool,secondsAgo);
        amountOut=OracleLibrary.getQuoteAtTick(tick,amountIn,tokenIn,tokenOut);
    }
}