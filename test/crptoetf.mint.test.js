const { ethers } = require("hardhat");
const ETFTOKENABI =
  require("../artifacts/contracts/CryptoETFToken.sol/CryptoETFToken.json").abi;
const ERC20ABI =
  require("../artifacts/@openzeppelin/contracts/token/ERC20/IERC20.sol/IERC20.json").abi;

//related contract address
const FACTORY = "0x1F98431c8aD98523631AE4a59f267346ea31F984";
const LINK = "0x514910771af9ca656af840dff83e8264ecf986ca";
const UNI = "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984";
const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const UNISWAPROUTER = "0xE592427A0AEce92De3Edee1F18E0157C05861564";

async function ignition() {
  const [twap, ceto, router, deployFactory] = await deploy();

  //create token
  const etf = await createETF(deployFactory);
  //purchase etf
  await purchaseETF(ceto, router, etf, "0.4");

  await checkResult(etf, ceto);
}

async function deploy() {
  console.log("======DEPLOY CONTRACT BEGIN=======");

  //deploy oracle
  const UniswapV3TWAP = await ethers.getContractFactory("UniswapV3TWAP");
  const twap = await UniswapV3TWAP.deploy(FACTORY);
  await twap.waitForDeployment();
  console.log("twap address=>", await twap.getAddress());
  const CryptoETFTokenOralce = await ethers.getContractFactory(
    "CryptoETFOracle"
  );
  const ceto = await CryptoETFTokenOralce.deploy(await twap.getAddress());
  await ceto.waitForDeployment();
  console.log("oracle address=>", await ceto.getAddress());
  //deploy router
  const routerContract = await ethers.getContractFactory("CryptoETFRouter");
  const router = await routerContract.deploy(ceto, UNISWAPROUTER, WETH);
  await router.waitForDeployment();
  console.log("cryptoetf router address=>", await router.getAddress());

  //deploy factory
  const deployFactoryContract = await ethers.getContractFactory(
    "CryptoETFTokenFactory"
  );
  const deployFactory = await deployFactoryContract.deploy(
    await router.getAddress(),
    ethers.ZeroAddress
  );
  await deployFactory.waitForDeployment();
  console.log("cryptoetf factory address=>", await deployFactory.getAddress());
  console.log("======DEPLOY CONTRACT SUCCESS,START TO CREARTE=======");
  return [twap, ceto, router, deployFactory];
}

async function createETF(etfFactory) {
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
  const etf = await etfFactory.createETF(name, symbol, tokenUri, constitunents);
  await etf.wait();
  let etfAddress = await etfFactory.etfListM("MTK");
  console.log(`MINT ETF===>${etfAddress}`);
  return etfAddress;
}

async function purchaseETF(ceto, router, etf, ethInput) {
  const [signer1] = await ethers.getSigners();
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

async function checkResult(etf, ceto) {
  const [signer1] = await ethers.getSigners();
  const link = await ethers.getContractAt(ERC20ABI, LINK);
  const uni = await ethers.getContractAt(ERC20ABI, UNI);

  const etfC = await ethers.getContractAt(ETFTOKENABI, etf);
  //检查etf reverse
  console.log("RESERVE LINK IN ETF=>", await etfC.constitunentsReserves(LINK));
  console.log("RESERVE UNI IN ETF=>", await etfC.constitunentsReserves(UNI));
  console.log("MINT TOTAL  ETF=>", await etfC.totalSupply());

  console.log("ERC20 LINK BALANCE=>", await link.balanceOf(etf));
  console.log("ERC20 UNI BALANCE=>", await uni.balanceOf(etf));
  console.log(
    "AFTER  EFT NAV=>",
    ethers.formatEther(await ceto.nav(etf, WETH, 10)),
    "ETH"
  );
}

ignition();
