require('dotenv').config();
require("@nomiclabs/hardhat-ethers");

module.exports = {
defaultNetwork: "gnosis",
  networks: {
    localhost: {
      url: 'http://127.0.0.1:8545',
    },
    // hardhat: {
    // },
    gnosis: {
      //url: 'https://rpc.gnosischain.com/',
      //url: 'https://rpc.ankr.com/gnosis',
      //url: 'https://gnosis-mainnet.public.blastapi.io',
      url: "https://gnosischain-rpc.gateway.pokt.network",
      gasPrice: 1000000000,
      gasLimit: 1000000,
      accounts: [process.env.dev_pk]
    },
    chiado: {
      url: 'https://rpc.chiadochain.net',
      gasPrice: 1000000000,
      accounts: [process.env.dev_pk]
    },
  },
   solidity: {
    compilers: [
      {
      version: "0.8.0"
      },
      {
      version: "0.8.1",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
      },
      ],
  },
};
