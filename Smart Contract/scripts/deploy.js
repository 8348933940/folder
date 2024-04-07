const hre = require("hardhat");

async function main() {
  
  const rto = await hre.ethers.deployContract("RTO", {
  });

  await rto.waitForDeployment();

  console.log(
    `RTO deployed to ${rto.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
