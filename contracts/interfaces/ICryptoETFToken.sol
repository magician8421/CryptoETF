// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
import "contracts/CryptoETFLibrary.sol";
interface ICryptoETFToken{
     function mint(uint256 etfAmount,address to) external ;
     function constitunents() external returns(CryptoETFLibrary.Constitunent[] memory);
}