// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
interface ICryptoETFTokenOralce{
        
    function price(address etfAddress,address targetToken) external returns(uint256);

}