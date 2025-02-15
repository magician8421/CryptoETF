// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
import "@openzeppelin/contracts/interfaces/IERC20.sol";
interface ICryptoETFToken is IERC20{
     struct  Constitunent{
        address tokenAddress;
        uint24 distribution;
    }

     function getConstitunents() external view returns(Constitunent[] calldata,uint24 totalConnsitunents);
     function modifyConsitunent(Constitunent[] calldata constitunents_) external;
}