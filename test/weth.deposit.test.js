const { ethers } = require("hardhat");
const abi = require("../assets/abi/weth.json");
let signer = new ethers.Wallet(
  "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80",
  ethers.provider
);

async function deposit() {
  let contract = new ethers.Contract(
    "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
    abi,
    signer
  );
  console.log(
    await contract.balanceOf("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
  );
  await contract.deposit({ value: BigInt(20 * 10 ** 18) });
  await contract.approve()

  console.log(
    await contract.balanceOf("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
  );
}

deposit();
