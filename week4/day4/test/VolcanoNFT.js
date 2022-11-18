const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
require("hardhat-gas-reporter");
const fs = require("fs");
const hre = require("hardhat");

describe("VolcanoNFT", function () {
  async function deployContract() {
    const VolcanoCoin = await hre.ethers.getContractFactory("VolcanoCoin");
    const volcanoCoin = await VolcanoCoin.deploy();
    await volcanoCoin.deployed();

    const VolcanoNFT = await hre.ethers.getContractFactory("VolcanoNFT");
    const volcanoNFT = await VolcanoNFT.deploy(volcanoCoin.address);
    await volcanoNFT.deployed();

    const [deployer, addr1, addr2] = await ethers.getSigners();
    return { volcanoNFT, volcanoCoin, deployer, addr1, addr2 };
  }

  describe("Deploying", function () {
    // NFT contract should have deployer as owner
    it("Should have the deployer as the owner", async function () {
      const { volcanoNFT, deployer } = await loadFixture(deployContract);
      expect(await volcanoNFT.owner()).to.equal(deployer.address);
    });

    // Deployer has total supply of VolcanoCoin
    it("Should allocate the deployer with total supply of VolcanoCoin", async function () {
      const { volcanoCoin, deployer } = await loadFixture(deployContract);
      expect(await volcanoCoin.balanceOf(deployer.address)).to.equal(
        await volcanoCoin.totalSupply()
      );
    });
  });

  describe("Minting", function () {
    it("Should mint a new NFT", async function () {
      const { volcanoNFT, deployer } = await loadFixture(deployContract);
      await volcanoNFT.mintWithETH(deployer.address, {
        value: ethers.utils.parseEther(".01"),
      });
      expect(await volcanoNFT.totalSupply()).to.equal(1);
    });

    it("Should not allow minting past max supply", async function () {
      const { volcanoNFT, deployer } = await loadFixture(deployContract);
      const max = await volcanoNFT.MAX_SUPPLY();

      // Mint up to the max supply
      for (let i = 0; i < max - 1; i++) {
        await volcanoNFT.mintWithETH(deployer.address, {
          value: ethers.utils.parseEther(".01"),
        });
      }

      expect(
        volcanoNFT.mintWithETH(deployer.address, {
          value: ethers.utils.parseEther(".01"),
        })
      ).to.be.revertedWith("Max supply reached");
      expect(await volcanoNFT.totalSupply()).to.equal(max);
    });

    it("Should not allow minting with incorrect ETH value", async function () {
      const { volcanoNFT, deployer } = await loadFixture(deployContract);
      await expect(
        volcanoNFT.mintWithETH(deployer.address, {
          value: ethers.utils.parseEther(".02"),
        })
      ).to.be.revertedWith("Incorrect ETH value");
    });

    it("Should allow users to mint with volcanoCoin", async function () {
      const { volcanoNFT, volcanoCoin, deployer } = await loadFixture(
        deployContract
      );
      const price = await volcanoNFT.TOKEN_PRICE();
      await volcanoCoin.approve(volcanoNFT.address, price);
      await volcanoNFT.mintWithVolcanoCoin(deployer.address);
      expect(await volcanoNFT.totalSupply()).to.equal(1);
    });

    it("Should not allow you to mint with someone else's VolcanoCoin", async function () {
      const { volcanoNFT, volcanoCoin, deployer, addr1 } = await loadFixture(
        deployContract
      );
      const tokenPrice = await volcanoNFT.TOKEN_PRICE();
      await volcanoCoin.approve(volcanoNFT.address, tokenPrice);

      await expect(
        volcanoNFT.connect(addr1).mintWithVolcanoCoin(deployer.address)
      ).to.be.reverted;
    });
  });

  describe("Transferring", function () {
    it("Should transfer an NFT", async function () {
      const { volcanoNFT, deployer, addr1 } = await loadFixture(deployContract);
      await volcanoNFT.mintWithETH(deployer.address, {
        value: ethers.utils.parseEther(".01"),
      });
      await volcanoNFT.transferFrom(deployer.address, addr1.address, 0);
      expect(await volcanoNFT.ownerOf(0)).to.equal(addr1.address);
    });

    it("Should not allow transferring when not owner", async function () {
      const { volcanoNFT, deployer, addr1 } = await loadFixture(deployContract);
      await volcanoNFT.mintWithETH(deployer.address, {
        value: ethers.utils.parseEther(".01"),
      });
      await expect(
        volcanoNFT
          .connect(addr1)
          .transferFrom(deployer.address, addr1.address, 0)
      ).to.be.revertedWith("ERC721: caller is not token owner nor approved");
    });
  });

  describe("Setting baseURI", function () {
    it("Should set the base URI", async function () {
      const { volcanoNFT, deployer } = await loadFixture(deployContract);
      await volcanoNFT.setBaseURI("https://example.com/");
      expect(await volcanoNFT.baseURI()).to.equal("https://example.com/");
    });

    it("Should only allow the owner to set the base URI", async function () {
      const { volcanoNFT, deployer, addr1 } = await loadFixture(deployContract);

      await expect(
        volcanoNFT.connect(addr1).setBaseURI("https://example.com/")
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });
  });

  describe("SVG Generation", function () {
    it("Should generate a SVG", async function () {
      const { volcanoNFT, deployer } = await loadFixture(deployContract);
      await volcanoNFT.mintWithETH(deployer.address, {
        value: ethers.utils.parseEther(".01"),
      });
      expect(await volcanoNFT.totalSupply()).to.equal(1);
      const svg = await volcanoNFT.generateSvg(1);
      console.log(svg);
      fs.writeFile("./test.svg", svg, (err) => {
        if (err) {
          console.error(err);
        }
      });
    });
  });
  describe("Metadata", function () {
    it("Should return the correct metadata", async function () {
      const { volcanoNFT, deployer } = await loadFixture(deployContract);
      await volcanoNFT.mintWithETH(deployer.address, {
        value: ethers.utils.parseEther(".01"),
      });
      expect(await volcanoNFT.totalSupply()).to.equal(1);
      const metadata = await volcanoNFT.tokenURI(1);
      console.log(metadata);
      // fs.writeFile("./test.json", metadata, (err) => {
      //   if (err) {
      //     console.error(err);
      //   }
    });
  });
});
