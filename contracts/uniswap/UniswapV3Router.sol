// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;
import "../libraries/PoolAddress.sol";
import "uniswap-v3-periphery-0.8/contracts/libraries/Path.sol";
import '@uniswap/v3-core/contracts/libraries/TickMath.sol';
import '@uniswap/v3-core/contracts/libraries/SafeCast.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import "hardhat/console.sol";
import "../interfaces/IWETH.sol";
contract UniswapV3Router{
    
    using Path for bytes;
    address factory=0x1F98431c8aD98523631AE4a59f267346ea31F984;
    using SafeCast for uint256;
    address  WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    struct SwapCallbackData {
        bytes path;
        address payer;
    }

struct ExactInputParams {
    uint256 amountIn;
    address recipient;
    uint160 sqrtPriceLimitX96;
    address tokenIn;
    address tokenOut;
    uint24 fee;
}
function exactInputInternal(
  ExactInputParams memory params
) external payable returns (uint256 amountOut)  {

    console.log(params.tokenIn);
    console.log(params.tokenOut);
   // consoel.log(type(UniswapV3Pool).creationCode());
    SwapCallbackData memory data = getSwapData(params.tokenIn, params.tokenOut, params.fee);
    if (params.recipient == address(0)) params.recipient = address(this);

    (address tokenIn, address tokenOut, uint24 fee) = data.path.decodeFirstPool();
    IUniswapV3Pool pool = getPool(tokenIn, tokenOut, fee);

    amountOut = _swap(
        pool,
        params.recipient,
        tokenIn < tokenOut, // zeroForOne
        params.amountIn.toInt256(),
        params.sqrtPriceLimitX96,
        data
    );
}

function _swap(
    IUniswapV3Pool pool,
    address recipient,
    bool zeroForOne,
    int256 amountIn,
    uint160 sqrtPriceLimitX96,
    SwapCallbackData memory data
) internal returns (uint256 amountOut) {

    (int256 amount0, int256 amount1) = pool.swap(
        recipient,
        zeroForOne,
        amountIn,
        sqrtPriceLimitX96 == 0
            ? (zeroForOne ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1)
            : sqrtPriceLimitX96,
        abi.encode(data)
    );

    return uint256(-(zeroForOne ? amount1 : amount0));
}
        /// @dev Returns the pool for the given token pair and fee. The pool contract may or may not exist.
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) public view returns (IUniswapV3Pool) {
        console.log(tokenA);
        console.log(tokenB);
        return IUniswapV3Pool(PoolAddress.computeAddress(factory, PoolAddress.getPoolKey(tokenA, tokenB, fee)));
    }


    function getSwapData(  address _tokenIn,
        address _tokenOut,
        uint24 _fee) private returns(SwapCallbackData memory){
        return  SwapCallbackData({path: abi.encodePacked(_tokenIn, _fee, _tokenOut), payer: msg.sender});
    }
}