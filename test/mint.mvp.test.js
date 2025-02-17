const { ethers } = require("hardhat");
const OracleAbi =
  require("../artifacts/contracts/CryptoETFOracle.sol/CryptoETFOracle.json").abi;
const RouterAbi =
  require("../artifacts/contracts/CryptoETFRouter.sol/CryptoETFRouter.json").abi;
const FactoryAbi =
  require("../artifacts/contracts/CryptoETFFactory.sol/CryptoETFTokenFactory.json").abi;
const helpers = require("@nomicfoundation/hardhat-toolbox/network-helpers");
// USDC
const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const LINK = "0x514910771af9ca656af840dff83e8264ecf986ca";
const UNI = "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984";
// WETH
const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
//UNISWAP ROUTER
const UNISWAPROUTER = "0xE592427A0AEce92De3Edee1F18E0157C05861564";
const FEE = 3000;

async function create_swap() {
  const [signer] = await ethers.getSigners();

  let routerAddress = "0x103416cfCD0D0a32b904Ab4fb69dF6E5B5aaDf2b";
  let oracleAddress = "0xd544d7A5EF50c510f3E90863828EAba7E392907A";
  let factoryAddress = "0x1F585372F116E1055AF2bED81a808DDf9638dCCD";
  //deploy token
  let factory = new ethers.Contract(factoryAddress, FactoryAbi, signer);
  const factoryAbi = await ethers.getContractFactory("CryptoETFToken");
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
  let etf;
  try {
    etf = await factory.createETF(name, symbol, tokenUri, constitunents);
    await etf.wait();
  } catch (error) {}
  let etfAddress = await factory.etfListM("MTK");
  console.log(await factory.etfs(0));

  //询价
  let ceto = new ethers.Contract(oracleAddress, OracleAbi, signer);
  console.log(await ceto.nav(etfAddress, WETH, 10));

  //mint
  //100s超时
  let deadline = Math.round(new Date().getTime() / 1000) + 100;
  let router = new ethers.Contract(routerAddress, RouterAbi, signer);
  await router.purchaseWithExactEth(etfAddress, signer.address, 0, deadline, {
    value: ethers.parseUnits("0.0004"),
  });
  console.log("balance eth=", await ethers.provider.getBalance(signer.address));
  //burn

  let redeemAmout = 100;
  await router.redeemWithExactEth(
    etfAddress,
    redeemAmout,
    signer.address,
    0,
    deadline
  );
  console.log("balance eth=", await ethers.provider.getBalance(signer.address));
}
create_swap();
