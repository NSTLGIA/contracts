const hre = require("hardhat");

async function main() {

  const poapAddr = "0x22c1f6050e56d2876009903609a2cc3fef83b415"
  const POAPRaffle = await hre.ethers.getContractFactory("POAPRaffle");
  const poapRaffle = await POAPRaffle.deploy(poapAddr);

  await poapRaffle.deployed();

  console.log("POAPRaffle deployed to:", poapRaffle.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });