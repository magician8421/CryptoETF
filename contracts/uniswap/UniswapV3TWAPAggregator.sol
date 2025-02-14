// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "uniswap-v3-periphery-0.8/contracts/libraries/OracleLibrary.sol";
import "hardhat/console.sol";
contract UniswapV3TWAPAggregator{

    address private immutable uniswapFactory;
    /**
     * twap factory using for get _pool
     */
    mapping(address=>mapping(address=>address)) private poolFactory;

    constructor(address _factory){
        uniswapFactory=_factory;
    }
    function initPool(address _token0,address _token1,uint24 _fee) public returns(address){
        
        (address _tokenFrom,address _tokenTo)=getOrderedToken(_token0,_token1);
        address _pool=poolFactory[_tokenFrom][_tokenTo];
        if(_pool==address(0)){
            _pool=IUniswapV3Factory(uniswapFactory).getPool(_tokenFrom,_tokenTo,_fee);
            require(_pool!=address(0),"pool dosen't exist");
            poolFactory[_tokenFrom][_tokenTo]=_pool;
        }
       return _pool;
        
    }   


    function estimateAmountOut(
        address tokenIn,
        address tokenOut,
        uint128 amountIn,
        uint32 secondsAgo
    )  external view  returns (uint amountOut) {
        (address _tokenFrom,address _tokenTo)=getOrderedToken(tokenIn,tokenOut);
        address _pool=poolFactory[_tokenFrom][_tokenTo];
        (int24 tick,)  =OracleLibrary.consult(_pool,secondsAgo);
        amountOut=OracleLibrary.getQuoteAtTick(tick,amountIn,tokenIn,tokenOut);
    }

    /**
     * reorder token0,token1 due to there's a same pool in uniswp no matter pair is (token0,token1) or (token1,token0)
     */
    function getOrderedToken(address _token0,address _token1) private pure returns(address,address){
        return _token0<_token1?(_token0,_token1):(_token1,_token0);
    }
}