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


   function purchaseWithEftAmout(uint256 eftAmount,address etfAddress,address to) external returns(uint256){
       //caculate mint count according to distribution
       CryptoETFLibrary.Constitunent[] memory _constitunents=ICryptoETFToken(etfAddress).constitunents();

       for(uint i=0;i<_constitunents.length;i++){
             CryptoETFLibrary.Constitunent memory _cons=_constitunents[i];
             //caculate token amout
         }
       ICryptoETFToken(etfAddress).mint(eftAmount, to) ;
       return 2;
    }
}