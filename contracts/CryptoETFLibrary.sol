// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
library CryptoETFLibrary{
        /**
     * Constitunent struct
     */
    struct  Constitunent{
        address tokenAddress;
        uint24 distribution;
    }

    
     struct  TokenDistribution{
        address tokenAddress;
        uint256 distributionAmount;
    }
  
}