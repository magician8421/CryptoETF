// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
import "./CryptoETFToken.sol";
import "./CryptoETFLibrary.sol";
import "./interfaces/ICryptoETFToken.sol";
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



    function purchaseWithExactEth(address etfAddress,uint256 minAmountOut ,address to) external payable returns(uint256){
        require(msg.value>0,"need send eth");
        //cal etf price using CryptoETFOracle
        //address etfAddress,address tokenIn, uint32 secondsAgo
        uint256 price= cryptoETFOracle.price(etfAddress,WETH,5);
        uint128 etfCount=uint128(msg.value/price);
        //calc constitunent token
        (CryptoETFLibrary.Constitunent[] memory _cons,uint24 _totalConstitunent)= ICryptoETFToken(etfAddress).getConstitunents();
        for(uint256 i=0;i<_cons.length;i++){
            address _token=_cons[i].tokenAddress;
            uint24 _distribution=_cons[i].distribution;
            uint128 _tokenAmount=etfCount*uint128(10)**IERC20Metadata(_token).decimals()*_distribution/_totalConstitunent;
            //invoke uniswap swap method   
        }

    }

    function redeemWithExactEth(address etfAddress,uint256 minAmountOut,address to) external{

    }

}