// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
import "./CryptoETFToken.sol";
import "./CryptoETFOracle.sol";
import "uniswap-v3-periphery-0.8/contracts/interfaces/ISwapRouter.sol";
import "./interfaces/IWETH.sol";
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
    CryptoETFOracle public cryptoETFOracle;

    //ISwapRouter 
    ISwapRouter   private     immutable router;
    


    
    //constructor
    constructor(CryptoETFOracle _cryptoETFOracle,ISwapRouter _router,address _weth) payable{
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
        uint256 amountIn=msg.value;
        //wrap eth to weth
        IWETH9(WETH).deposit{value:amountIn}();
        //approve weth to router
        IWETH9(WETH).approve(address(router),amountIn);
        uint256 nav=cryptoETFOracle.IDO_PRICE();
        //if it's first time to mint using caculated IDO PRCIE
        if(CryptoETFToken(etfAddress).totalSupply()>0){
           nav=cryptoETFOracle.nav(etfAddress,WETH,10);
        }
        //calc constitunent token and swap to router
        mintAmount=msg.value/nav*10**CryptoETFToken(etfAddress).decimals();
        (address[] memory tokensOuts, uint256[] memory amountOuts)= _swapByConstitunent(etfAddress,WETH,amountIn,deadline);
        CryptoETFToken(etfAddress).mint(mintAmount,to,tokensOuts,amountOuts);
        require(mintAmount>=minAmountOut,"amountOut is less than minAmountOut");
    }

    /**
     * redeem etf to eth
     * @param etfAddress the address of etf
     * @param to  address to recieve eth
     * @param minAmountOut min amout out of eth expected
     * @param deadline transaction timeout
     */
    function redeemWithExactEth(address etfAddress,uint256 redeemAmount,address to,uint256 minAmountOut,uint256 deadline) external payable returns(uint256 amountOut){
        require(redeemAmount>0,"redeem amount need greater than zero");
        uint256 _totalSupply=CryptoETFToken(etfAddress).totalSupply();
        require(_totalSupply>0,"no enough etf can be redeemed");

        //first burn etf  receive constitunents
       (address[] memory constitunentTokens,uint256[] memory constitunentAmounts) =CryptoETFToken(etfAddress).burn(redeemAmount,msg.sender);
       for(uint256 i=0;i<constitunentTokens.length;i++){
            address _token=constitunentTokens[i];
            //approve uniswap to 
            CryptoETFToken(_token).approve(address(router),constitunentAmounts[i]);
            //invoke uniswap swap method  to swap token to etf  
            amountOut+=router.exactInputSingle(ISwapRouter.ExactInputSingleParams({
                tokenIn:_token,
                tokenOut:WETH,
                fee:3000,       
                recipient:address(this),
                deadline:deadline,
                amountIn:constitunentAmounts[i],
                amountOutMinimum:0,
                sqrtPriceLimitX96:0
            }));
        }


        require(amountOut>=minAmountOut,"amountOut is less than minAmountOut");
        //swap weth to eth 
         IWETH9(WETH).withdraw(amountOut);
         //send eth to address to
         payable(to).transfer(amountOut);


    }

    /**
     * mint constitunent token according to the constitunent list
     * value of each token= eth * distribution/totalConstitunent
     */
    function _swapByConstitunent(address _etfAddress,address _tokenIn,uint256 amountIn,uint256 _deadline)  private returns(address[] memory tokensOuts, uint256[] memory amountOuts){
       (CryptoETFToken.Constitunent[] memory _cons,uint24 _totalConstitunent)= CryptoETFToken(_etfAddress).getConstitunents();
       tokensOuts=new address[](_cons.length);
       amountOuts=new uint256[](_cons.length);

       for(uint256 i=0;i<_cons.length;i++){
            address _token=_cons[i].tokenAddress;
            //tokenprice 
            uint256 amountInForConstitunent=amountIn*_cons[i].distribution/_totalConstitunent;
            //invoke uniswap swap method  to swap token to etf  
            // Perform swap
            SwapParams memory params = SwapParams({
                tokenIn: _tokenIn,
                tokenOut: _token,
                amountIn: amountInForConstitunent,
                deadline: _deadline,
                recipient: _etfAddress
            });
            uint256 _amountOut=_swapToken(params);
            tokensOuts[i]=_token;
            amountOuts[i]=_amountOut;
       }
    }
 

    function _swapToken(SwapParams memory params)   private  returns (uint256 _amountOut){
         _amountOut=router.exactInputSingle(ISwapRouter.ExactInputSingleParams({
                tokenIn:params.tokenIn,
                tokenOut:params.tokenOut,
                fee:3000,       
                recipient:params.recipient,
                deadline:params.deadline,
                amountIn:params.amountIn,
                amountOutMinimum:0,
                sqrtPriceLimitX96:0
            }));
    }


    //use struct to reduce stack-too-deep error
    struct SwapParams {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 deadline;
        address recipient;
    }

    /**
     * need recieve eth when execute IWETH.withdraw
     */
    receive() external payable {
        
    }

}