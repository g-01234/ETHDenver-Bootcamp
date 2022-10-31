const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

const hre = require("hardhat");

describe("VolcanoNFT", function () {
  async function deployContract() {
    const VolcanoNFT = await hre.ethers.getContractFactory("VolcanoNFT");
    const volcanoNFT = await VolcanoNFT.deploy();
    const [deployer, otherOne, otherTwo] = await ethers.getSigners();
    await volcanoNFT.deployed();
    return { volcanoNFT, deployer, otherOne, otherTwo };
  }

  describe("Deploying", function () {
    it("Should have the deployer as the owner", async function () {
      const { volcanoNFT, deployer } = await loadFixture(deployContract);
      expect(await volcanoNFT.owner()).to.equal(deployer.address);
    });
  });

  describe("Minting", function () {
    it("Should mint a new NFT", async function () {
      const { volcanoNFT, deployer } = await loadFixture(deployContract);
      await volcanoNFT.mint(deployer.address);
      expect(await volcanoNFT.totalSupply()).to.equal(1);
    });

    it("Should not allow minting past max supply", async function () {
      const { volcanoNFT, deployer } = await loadFixture(deployContract);
      const max = await volcanoNFT.MAX_SUPPLY();

      // Mint up to the max supply
      for (let i = 0; i < max - 1; i++) {
        await volcanoNFT.mint(deployer.address);
      }

      expect(await volcanoNFT.mint(deployer.address)).to.be.revertedWith(
        "Max supply reached"
      );
      expect(await volcanoNFT.totalSupply()).to.equal(max);
    });
  });

  describe("Transferring", function () {
    it("Should transfer an NFT", async function () {
      const { volcanoNFT, deployer, otherOne } = await loadFixture(
        deployContract
      );
      await volcanoNFT.mint(deployer.address);
      await volcanoNFT.transferFrom(deployer.address, otherOne.address, 0);
      expect(await volcanoNFT.ownerOf(0)).to.equal(otherOne.address);
    });

    it("Should not allow transferring when not owner", async function () {
      const { volcanoNFT, deployer, otherOne } = await loadFixture(
        deployContract
      );
      await volcanoNFT.mint(deployer.address);
      await expect(
        volcanoNFT
          .connect(otherOne)
          .transferFrom(deployer.address, otherOne.address, 0)
      ).to.be.revertedWith("ERC721: caller is not token owner nor approved");
    });
  });
});
