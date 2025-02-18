const { ethers } = require("hardhat");
const { getSavedContractAddresses } = require("../configs/scripts/utils");
const ETFTOKENABI =
  require("../artifacts/contracts/CryptoETFToken.sol/CryptoETFToken.json").abi;
const ERC20ABI =
  require("../artifacts/@openzeppelin/contracts/token/ERC20/IERC20.sol/IERC20.json").abi;
const CETOABI =
  require("../artifacts/contracts/CryptoETFOracle.sol/CryptoETFOracle.json").abi;
const ROUTERABI =
  require("../artifacts/contracts/CryptoETFRouter.sol/CryptoETFRouter.json").abi;
const ETFFACTORYABI =
  require("../artifacts/contracts/CryptoETFFactory.sol/CryptoETFTokenFactory.json").abi;

//related contract address
const LINK = "0x514910771af9ca656af840dff83e8264ecf986ca";
const UNI = "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984";
const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";

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

//etf contract
const cetoAddress = getSavedContractAddresses()[hre.network.name]["CETO"];
const routerAddress =
  getSavedContractAddresses()[hre.network.name]["ETFROUTER"];
const factoryAddress =
  getSavedContractAddresses()[hre.network.name]["ETFFACTORY"];

async function ignition() {
  const [ceto, router, factory] = await getContract();

  //purchase etf
  const etfAddress = await createETF(factory);
  await purchaseETF(ceto, router, etfAddress, "0.4");
  await checkResult(etfAddress, ceto);
  //sale etf
  await saleETF(ceto, router, etfAddress, 200);
  await checkResult(etfAddress, ceto);
}

async function getContract() {
  let ceto = await ethers.getContractAt(CETOABI, cetoAddress);
  let router = await ethers.getContractAt(ROUTERABI, routerAddress);
  let factory = await ethers.getContractAt(ETFFACTORYABI, factoryAddress);
  return [ceto, router, factory];
}

async function createETF(etfFactory) {
  const name = "MyToken";
  const symbol = "MTK";
  const tokenUri = "https://example.com/token/1";
  try {
    const etf = await etfFactory.createETF(
      name,
      symbol,
      tokenUri,
      constitunents
    );
    await etf.wait();
  } catch (e) {
    console.log(e);
  }
  let etfAddress = await etfFactory.etfListM("MTK");
  console.log(`MINT ETF===>${etfAddress}`);
  return etfAddress;
}

async function purchaseETF(ceto, router, etf, ethInput) {
  const [signer1] = await ethers.getSigners();
  console.log(
    "USER ETH=>",
    ethers.formatEther(await ethers.provider.getBalance(signer1.address))
  );
  let deadline = Math.round(new Date().getTime() / 1000) + 100;
  console.log("INPUT ETH=>", ethInput, "ETH");
  console.log(
    "IDO EFT NAV=>",
    ethers.formatEther(await ceto.nav(etf, WETH, 10)),
    "ETH"
  );
  await router.purchaseWithExactEth(etf, signer1.address, 0, deadline, {
    value: ethers.parseUnits(ethInput),
  });
}

async function saleETF(ceto, router, etf, etfAmount) {
  console.log(`======BEGIN TO SALE ETF =====`);
  const [signer1] = await ethers.getSigners();
  let deadline = Math.round(new Date().getTime() / 1000) + 100;
  console.log("SALE ETF TOKEN=>", etfAmount, "ETF");

  await router.redeemWithExactEth(etf, etfAmount, signer1.address, 0, deadline);
}

async function checkResult(etf, ceto) {
  console.log("======BEGIN TO CHECK STATE=====");
  const [signer1] = await ethers.getSigners();
  const etfC = await ethers.getContractAt(ETFTOKENABI, etf);
  console.log("MINT TOTAL  ETF=>", await etfC.totalSupply());
  //检查etf reverse
  for (const _consti of constitunents) {
    let _token = await ethers.getContractAt(ERC20ABI, _consti.tokenAddress);
    console.log(
      "RESERVE %s IN ETF=>%s",
      _consti.tokenAddress,
      await etfC.constitunentsReserves(_consti.tokenAddress)
    );
    console.log(
      "ERC20 %s BALANCE=>",
      _consti.tokenAddress,
      await _token.balanceOf(etf)
    );
  }
  console.log(
    "AFTER  EFT NAV=>",
    ethers.formatEther(await ceto.nav(etf, WETH, 10)),
    "ETH"
  );
  console.log(
    "USER ETH=>",
    ethers.formatEther(await ethers.provider.getBalance(signer1.address))
  );
}
ignition();
