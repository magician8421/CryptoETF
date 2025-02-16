const { ethers } = require("hardhat");
const abi = require("../manual_abi/weth.json");
let signer = new ethers.Wallet(
  "df57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e",
  ethers.provider
);

async function deposit() {
  console.log(await ethers.provider.getBlockNumber());
  let contract = new ethers.Contract(
    "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
    abi,
    signer
  );

  let response = await contract.deposit({ value: BigInt(20 * 10 ** 18) });
  console.log(await response.wait(1));
  console.log(
    await contract.balanceOf("0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199")
  );
  console.log(await ethers.provider.getBlockNumber());
  await showEth();
}

async function showEth() {
  let contract = new ethers.Contract(
    "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
    abi,
    signer
  );

  console.log(
    await contract.balanceOf("0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199")
  );
  console.log(await ethers.provider.getBlockNumber());
}
showEth();
