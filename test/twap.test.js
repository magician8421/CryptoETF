const { expect } = require("chai");
const { ethers } = require("hardhat");

const FACTORY = "0x1F98431c8aD98523631AE4a59f267346ea31F984";
// USDC
const TOKEN_0 = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
// WETH
const TOKEN_1 = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const DECIMALS_1 = 18n;
// 0.3%
const FEE = 3000;
// Pair
// 0x8ad599c3A0ff1De082011EFDDc58f1908eb6e6D8

async function testTwap() {
  const UniswapV3Twap = await ethers.getContractFactory("UniswapV3TWAP");
  const twap = await UniswapV3Twap.deploy(FACTORY);
  await twap.waitForDeployment();

  const price = await twap.estimateAmountOut(
    TOKEN_1,
    TOKEN_0,
    10n ** DECIMALS_1,
    10
  );

  console.log(`price: ${price}`);
}

testTwap();
