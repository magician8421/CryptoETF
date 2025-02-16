const { expect } = require("chai");
const { ethers } = require("hardhat");

const FACTORY = "0x1F98431c8aD98523631AE4a59f267346ea31F984";
// USDC
const TOKEN_0 = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
// WETH
const TOKEN_1 = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const DECIMALS_1 = 18n;
// 0.3%

async function swap() {
  const routerContract = await ethers.getContractFactory("UniswapV3Router");
  const router = await routerContract.deploy();
  const params = {
    amountIn: ethers.parseUnits("0.2"), // 替换为实际的 token 地址
    recipient: "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
    sqrtPriceLimitX96: 0,
    tokenIn: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
    tokenOut: "0x514910771af9ca656af840dff83e8264ecf986ca",
    fee: 30000, // 替换为实际的 distribution 值
  };
  await router.exactInputInternal(params);
}

swap();
