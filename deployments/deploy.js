const { ethers } = require("hardhat");

const UNISWAP_FACTORY = "0x1F98431c8aD98523631AE4a59f267346ea31F984";
const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
//UNISWAP ROUTER
const UNISWAPROUTER = "0xE592427A0AEce92De3Edee1F18E0157C05861564";

async function deploy() {
  console.log("======DEPLOY CONTRACT BEGIN=======");

  //deploy oracle
  const UniswapV3TWAP = await ethers.getContractFactory("UniswapV3TWAP");
  const twap = await UniswapV3TWAP.deploy(UNISWAP_FACTORY);
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
  console.log("======DEPLOY CONTRACT SUCCESS======");
  return [twap, ceto, router, deployFactory];
}

deploy();
