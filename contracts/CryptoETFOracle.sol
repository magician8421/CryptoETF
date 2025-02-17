// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
import "./interfaces/ICryptoETFToken.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./uniswap/UniswapV3TWAP.sol";
import "./CryptoETFToken.sol";
import "@uniswap/v3-core/contracts/libraries/SafeCast.sol";
contract CryptoETFOracle{

    UniswapV3TWAP  public uniswapV3TWAP;

    uint256 constant public IDO_PRICE = 0.002 ether;

    constructor(UniswapV3TWAP _uniswapV3TWAP ){
        uniswapV3TWAP=_uniswapV3TWAP;
    }
    function nav(address etfAddress,address tokenOut, uint32 secondsAgo) external view returns(uint256){
      uint256 totalSupply=ICryptoETFToken(etfAddress).totalSupply();
      if(totalSupply==0){
        return IDO_PRICE;
      }
      (ICryptoETFToken.Constitunent[] memory _cons,)= ICryptoETFToken(etfAddress).getConstitunents();
      uint256 totalValue=0;
      for(uint256 i=0;i<_cons.length;i++){
        address _token=_cons[i].tokenAddress;
        //query constitunents price
        uint256 _tokenAmount=CryptoETFToken(etfAddress).constitunentsReserves(_token);
        totalValue+= uniswapV3TWAP.estimateAmountOut(_token,tokenOut,uint128(_tokenAmount),secondsAgo);
      }
      return totalValue/ ICryptoETFToken(etfAddress).totalSupply();
    }

}