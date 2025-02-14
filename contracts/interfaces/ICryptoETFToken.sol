// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
import "contracts/CryptoETFLibrary.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
interface ICryptoETFToken is IERC20{
     function mint(uint256 etfAmount,address to) external ;
     function getConstitunents() external view returns(CryptoETFLibrary.Constitunent[] calldata,uint24 totalConnsitunents);
}