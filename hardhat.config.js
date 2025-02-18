require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks: {
    hardhat: {
      forking: {
        url: "https://eth-mainnet.g.alchemy.com/v2/I3eHFhWUQaZueOZP5BPt3jdFLebK9aEe",
        blockNumber: 21864782,
      },
    },
    docker_fork: {
      url: "http://127.0.0.1:8000",
    },
  },
};
