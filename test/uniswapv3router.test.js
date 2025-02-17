const { expect } = require("chai");
const { ethers } = require("hardhat");
const abi = require("../assets/abi/weth.json");
const IUniswapV3PoolABI =
  require("@uniswap/v3-core/artifacts/contracts/interfaces/IUniswapV3Pool.sol/IUniswapV3Pool.json").abi;

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
  await deposit(await router.getAddress());
  await router.exactInputInternal(params);
}

async function pool() {
  // 获取 Uniswap V3 Router 合约工厂
  const routerContract = await ethers.getContractFactory("UniswapV3Router");
  const router = await routerContract.deploy();

  // 获取池子地址
  const tokenA = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"; // WETH
  const tokenB = "0x514910771af9ca656af840dff83e8264ecf986ca"; // LINK
  const fee = 30000; // 0.3% fee tier

  const poolAddress = await router.getPool(tokenA, tokenB, fee);

  if (poolAddress === "0x00000000000000000000") {
    console.error("Pool does not exist for the given tokens and fee tier.");
    return;
  }

  console.log("Pool Address:", poolAddress);

  // 初始化池子合约实例
  const poolContract = new ethers.Contract(
    poolAddress,
    IUniswapV3PoolABI,
    ethers.provider
  );

  // 检查池子是否已初始化
  const slot0 = await poolContract.slot0();
  if (slot0.sqrtPriceX96.toString() === "0") {
    console.error("Pool is not initialized.");
    return;
  }

  // 调用 liquidity() 方法
  const liquidity = await poolContract.liquidity();
  console.log("Pool Liquidity:", liquidity.toString());
}

async function deposit(routerAddress) {
  let contract = new ethers.Contract(
    "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
    abi,
    signer
  );
  await contract.deposit({ value: BigInt(20 * 10 ** 18) });
  await contract.approve(routerAddress, BigInt(20 * 10 ** 18));

  console.log(
    "weth balance",
    await contract.balanceOf("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
  );
  console.log(
    "weth allowance",
    await contract.allowance(
      "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
      routerAddress
    )
  );
}

pool();
