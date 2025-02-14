const { ethers } = require("hardhat");

const FACTORY = "0x1F98431c8aD98523631AE4a59f267346ea31F984";
// USDC
const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const LINK = "0x514910771af9ca656af840dff83e8264ecf986ca";
const UNI = "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984";
// WETH
const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const FEE = 3000;
async function checkEtfPrice() {
  //deploy router
  //deploy token
  const etfContract = await ethers.getContractFactory("CryptoETFToken");
  const zeroAddress = "0x0000000000000000000000000000000000000000";

  const constitunents = [
    {
      tokenAddress: LINK, // 替换为实际的 token 地址
      distribution: 5000, // 替换为实际的 distribution 值
    },
    {
      tokenAddress: UNI, // 替换为实际的 token 地址
      distribution: 5000, // 替换为实际的 distribution 值
    },
  ];
  const name = "MyToken";
  const symbol = "MTK";
  const tokenUri = "https://example.com/token/1";
  const etf = await etfContract.deploy(
    name,
    symbol,
    tokenUri,
    constitunents,
    zeroAddress,
    zeroAddress
  );
  await etf.waitForDeployment();
  //deploy oracle
  const UniswapV3TWAPAggregator = await ethers.getContractFactory(
    "UniswapV3TWAPAggregator"
  );
  const twap = await UniswapV3TWAPAggregator.deploy(FACTORY);
  await twap.waitForDeployment();
  console.log(await twap.getAddress());
  await (await twap.initPool(LINK, WETH, FEE)).wait();
  await (await twap.initPool(UNI, WETH, FEE)).wait();
  const CryptoETFTokenOralce = await ethers.getContractFactory(
    "CryptoETFOracle"
  );
  const ceto = await CryptoETFTokenOralce.deploy(await twap.getAddress());
  await ceto.waitForDeployment();
  console.log(await ceto.price(await etf.getAddress(), WETH, 10));
  //deploy
}
checkEtfPrice();
