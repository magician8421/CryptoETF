// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
import "./CryptoETFToken.sol";
import "./CryptoETFLibrary.sol";
import "./interfaces/ICryptoETFToken.sol";
import "./CryptoETFToken.sol";
import "./CryptoETFOracle.sol";
import "uniswap-v3-periphery-0.8/contracts/interfaces/ISwapRouter.sol";

pragma solidity 0.8.28;
contract CryptoETFRouter{
    using CryptoETFLibrary for CryptoETFLibrary.Constitunent;

    // WETH
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    CryptoETFOracle private cryptoETFOracle;

    //ISwapRouter 
    ISwapRouter private immutable router;

    
    //constructor
    constructor(CryptoETFOracle _cryptoETFOracle,ISwapRouter _router){
        cryptoETFOracle=_cryptoETFOracle;
        router=_router;
    }



    function purchaseWithExactEth(address etfAddress ,address to) external payable returns(uint256){
        require(msg.value>0,"need send eth");
        //if it's first time to mint using caculated IDO PRCIE
        if(ICryptoETFToken(etfAddress).totalSupply()==0){
            
           //calc constitunent token and swap to router
           _mintByConstitunent(etfAddress,msg.value);
           //caculate sharecount and mint 100 fixed as 
           CryptoETFToken(etfAddress).mint(100,to);
    

        }else{
            //calc constitunent token and swap to router
            _mintByConstitunent(etfAddress,msg.value);
            //caculate current etf price
            uint256 nav=cryptoETFOracle.NAV(etfAddress,WETH,10);
            uint256 share=msg.value/nav;
            CryptoETFToken(etfAddress).mint(share,to);

        }
        //cal etf price using CryptoETFOracle

    }

    function redeemWithExactEth(address etfAddress,uint256 amountOut,address to) external{
        require(amountOut>0,"redeem amount need greater than zero");
        uint256 _totalSupply=ICryptoETFToken(etfAddress).totalSupply();
        require(_totalSupply>0,"no enough etf can be redeemed");
        uint24 _portion= uint24(amountOut/_totalSupply);
       (CryptoETFLibrary.Constitunent[] memory _cons,)= ICryptoETFToken(etfAddress).getConstitunents();
       for(uint256 i=0;i<_cons.length;i++){
            address _token=_cons[i].tokenAddress;
            uint256 _constitunentReserve=CryptoETFToken(etfAddress).constitunentsReserves(_token);
            require(_constitunentReserve>0,"no enough constitunent token can be reddemed");
            uint256 _burnAmount=_constitunentReserve*_portion;
            //invoke uniswap swap method  to swap token to etf  
        }


    }

    /**
     * mint constitunent token according to the constitunent list
     * value of each token= eth * distribution/totalConstitunent
     */
    function _mintByConstitunent(address etfAddress,uint256 ethValue) view  private{
       (CryptoETFLibrary.Constitunent[] memory _cons,uint24 _totalConstitunent)= ICryptoETFToken(etfAddress).getConstitunents();
       for(uint256 i=0;i<_cons.length;i++){
            address _token=_cons[i].tokenAddress;
            uint24 _distribution=_cons[i].distribution;
            uint256 _tokenValue=ethValue*_distribution/_totalConstitunent;
            uint256 _tokenPrice=cryptoETFOracle.price(_token,WETH,5);
            uint256 _mintAmount=_tokenValue/_tokenPrice;
            //invoke uniswap swap method  to swap token to etf  
        }
    }

}