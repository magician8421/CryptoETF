// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
import "./interfaces/ICryptoETFToken.sol";
import "./CryptoETFLibrary.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./uniswap/UniswapV3TWAPAggregator.sol";
contract CryptoETFOracle{

    UniswapV3TWAPAggregator  uniswapV3TWAPAggregator;
    constructor(UniswapV3TWAPAggregator _uniswapV3TWAPAggregator ){
        uniswapV3TWAPAggregator=_uniswapV3TWAPAggregator;
    }
    function price(address etfAddress,address tokenIn, uint32 secondsAgo) external view returns(uint256){
      (CryptoETFLibrary.Constitunent[] memory _cons,uint24 _totalConstitunent)= ICryptoETFToken(etfAddress).getConstitunents();
      uint256 amountOut;
      for(uint256 i=0;i<_cons.length;i++){
        address _token=_cons[i].tokenAddress;
        uint24 _distribution=_cons[i].distribution;
        uint128 _tokenAmount=uint128(10)**IERC20Metadata(_token).decimals()*_distribution/_totalConstitunent;
        amountOut+= uniswapV3TWAPAggregator.estimateAmountOut(_token,tokenIn,_tokenAmount,secondsAgo);
      }
      return amountOut;
    }

}