// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
import "contracts/CryptoETFToken.sol";
import "contracts/CryptoETFLibrary.sol";
import "contracts/interfaces/ICryptoETFToken.sol";
pragma solidity 0.8.28;
contract CryptoETFRouter{
   using CryptoETFLibrary for CryptoETFLibrary.Constitunent;

    //UniswapOracle
    //Uniswap


   function purchaseWithExactEth(address etfAddress,uint256 minAmountOut ,address to) external payable returns(uint256){
       //caculate mint count according to distribution
    //    CryptoETFLibrary.Constitunent[] memory _constitunents=ICryptoETFToken(etfAddress).getConstitunents();

    //    for(uint i=0;i<_constitunents.length;i++){
    //          CryptoETFLibrary.Constitunent memory _cons=_constitunents[i];
    //          //caculate token amout
    //      }
    //   // ICryptoETFToken(etfAddress).mint(eftAmount, to) ;
    //    return 2;
    }

    function redeemWithExactEth(address etfAddress,uint256 minAmountOut,address to) external{

    }

}