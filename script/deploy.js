const hre = require("hardhat");

async function main() {
  const SEL_TOKEN_ADDRESS = "0xA1015816daadb6BA0f57b1eb67d7BAE06698873a"; // Replace with actual SEL token address on Selendra

  const OrangeGus = await hre.ethers.getContractFactory("OrangeGus");
  const orangeGus = await OrangeGus.deploy(SEL_TOKEN_ADDRESS);

  await orangeGus.deployed();

  console.log("OrangeGus deployed to:", orangeGus.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});