const { ethers } = require("hardhat");

const UNISWAP_FACTORY = "0x1F98431c8aD98523631AE4a59f267346ea31F984";
const LINK = "0x514910771af9ca656af840dff83e8264ecf986ca";
const UNI = "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984";
// WETH
const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
//UNISWAP ROUTER
const UNISWAPROUTER = "0xE592427A0AEce92De3Edee1F18E0157C05861564";
const FEE = 3000;

async function deploy() {
  const [signer1] = await ethers.getSigners();

  //deploy UniswapV3TWAPAggregator
  const UniswapV3TWAPAggregator = await ethers.getContractFactory(
    "UniswapV3TWAPAggregator"
  );
  const twap = await UniswapV3TWAPAggregator.deploy(UNISWAP_FACTORY);
  await twap.waitForDeployment();
  console.log("twap address=>", await twap.getAddress());
  await (await twap.initPool(LINK, WETH, FEE)).wait();
  await (await twap.initPool(UNI, WETH, FEE)).wait();

  //deploy oracle
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
    "0x0000000000000000000000000000000000000000"
  );
  await deployFactory.waitForDeployment();
  console.log("cryptoetf factory address=>", await deployFactory.getAddress());
}
deploy();
