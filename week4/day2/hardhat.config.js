require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.6.0",
  networks: {
    hardhat: {
      forking: {
        url: process.env.ALCHEMY_URL,
        accounts: [process.env.DEV_PRIVATE_KEY],
        enabled: true,
      },
    },
  },
};
