require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY;

console.log("PRIVATE_KEY:", PRIVATE_KEY); // Add this line for debugging

module.exports = {
  solidity: "0.8.20",
  networks: {
    selendra: {
      url: "https://rpc-testnet.selendra.org", // Selendra RPC URL
      chainId: 1953, // Selendra chainId (for testnet)
      accounts: [PRIVATE_KEY],
    },
  },
};