// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
/**
 * @title ICryptoETFToken
 * @author wayne.tong
 * @notice 
 */
interface ICryptoETFTokenOralce{
        
    function NAV(address etfAddress,address targetToken) external returns(uint256);

}