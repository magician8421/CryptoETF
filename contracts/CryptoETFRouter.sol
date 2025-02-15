// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
import "./CryptoETFToken.sol";
import "./interfaces/ICryptoETFToken.sol";
import "./CryptoETFToken.sol";
import "./CryptoETFOracle.sol";
import "uniswap-v3-periphery-0.8/contracts/interfaces/ISwapRouter.sol";

pragma solidity 0.8.28;
/**
 * @title CryptoETFRouter
 * @author Wayne.tong
 * @notice 
 */
contract CryptoETFRouter{ 


    // WETH
    address immutable WETH;
    //ORACLE
    CryptoETFOracle private  cryptoETFOracle;

    //ISwapRouter 
    ISwapRouter   private     immutable router;

    
    //constructor
    constructor(CryptoETFOracle _cryptoETFOracle,ISwapRouter _router,address _weth){
        cryptoETFOracle=_cryptoETFOracle;
        router=_router;
        WETH=_weth;
    }


    /**
     * purchase etf using eth
     * @param etfAddress the address of etf
     * @param to  address etf mint to
     * @param minAmountOut min amout out of etf expected
     * @param deadline transaction timeout
     */
    function purchaseWithExactEth(address etfAddress ,address to,uint256 minAmountOut,uint256 deadline) external payable returns(uint256 mintAmount){
        require(msg.value>0,"need send eth");
        mintAmount=100;
        //if it's first time to mint using caculated IDO PRCIE
        if(ICryptoETFToken(etfAddress).totalSupply()==0){
            
           //calc constitunent token and swap to router
           (address[] memory tokensOuts, uint256[] memory amountOuts)=_mintByConstitunent(etfAddress,WETH,msg.value,deadline);
           //caculate sharecount and mint 100 fixed as 
           CryptoETFToken(etfAddress).mint(mintAmount,to,tokensOuts,amountOuts);
    

        }else{
            //calc constitunent token and swap to router
           (address[] memory tokensOuts, uint256[] memory amountOuts)= _mintByConstitunent(etfAddress,WETH,msg.value,deadline);
            //caculate current etf price
            uint256 nav=cryptoETFOracle.NAV(etfAddress,WETH,10);
            mintAmount=msg.value/nav;
            CryptoETFToken(etfAddress).mint(mintAmount,to,tokensOuts,amountOuts);

        }
        require(mintAmount>=minAmountOut,"amountOut is less than minAmountOut");
    }

    /**
     * redeem etf to eth
     * @param etfAddress the address of etf
     * @param to  address to recieve eth
     * @param minAmountOut min amout out of eth expected
     * @param deadline transaction timeout
     */
    function redeemWithExactEth(address etfAddress,uint256 redeemAmount,address to,uint256 minAmountOut,uint256 deadline) external returns(uint256 amountOut){
        require(redeemAmount>0,"redeem amount need greater than zero");
        uint256 _totalSupply=ICryptoETFToken(etfAddress).totalSupply();
        require(_totalSupply>0,"no enough etf can be redeemed");
        uint24 _portion= uint24(redeemAmount/_totalSupply);
       (ICryptoETFToken.Constitunent[] memory _cons,)= ICryptoETFToken(etfAddress).getConstitunents();
       for(uint256 i=0;i<_cons.length;i++){
            address _token=_cons[i].tokenAddress;
            uint256 _constitunentReserve=CryptoETFToken(etfAddress).constitunentsReserves(_token);
            require(_constitunentReserve>0,"no enough constitunent token can be reddemed");
            uint256 _burnAmount=_constitunentReserve*_portion;
            //invoke uniswap swap method  to swap token to etf  
            amountOut+=router.exactInputSingle(ISwapRouter.ExactInputSingleParams({
                tokenIn:_token,
                tokenOut:WETH,
                fee:30000,       
                recipient:to,
                deadline:deadline,
                amountIn:_burnAmount,
                amountOutMinimum:0,
                sqrtPriceLimitX96:0
            }));
        }
        require(amountOut>=minAmountOut,"amountOut is less than minAmountOut");


    }

    /**
     * mint constitunent token according to the constitunent list
     * value of each token= eth * distribution/totalConstitunent
     */
    function _mintByConstitunent(address _etfAddress,address _tokenIn,uint256 _swapAmount,uint256 _deadline)  private returns(address[] memory tokensOuts, uint256[] memory amountOuts){
       (ICryptoETFToken.Constitunent[] memory _cons,uint24 _totalConstitunent)= ICryptoETFToken(_etfAddress).getConstitunents();
       tokensOuts=new address[](_cons.length);
       amountOuts=new uint256[](_cons.length);
       for(uint256 i=0;i<_cons.length;i++){
            address _token=_cons[i].tokenAddress;
            uint256 _mintAmount=(_swapAmount*_cons[i].distribution/_totalConstitunent)/(cryptoETFOracle.price(_token,WETH,5));
            //invoke uniswap swap method  to swap token to etf  
            uint256 _amountOut=router.exactInputSingle(ISwapRouter.ExactInputSingleParams({
                tokenIn:_tokenIn,
                tokenOut:_token,
                fee:30000,       
                recipient:_etfAddress,
                deadline:_deadline,
                amountIn:_mintAmount,
                amountOutMinimum:0,
                sqrtPriceLimitX96:0
            }));
            tokensOuts[i]=_token;
            amountOuts[i]=_amountOut;
       }
    }

}