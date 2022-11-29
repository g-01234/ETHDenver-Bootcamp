const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const hre = require("hardhat");

// ABIs
const uniAbi = require("../abi/UniV3Router.json");
const daiAbi = require("../abi/DAI.json");
const usdcAbi = require("../abi/DAI.json"); // unless?
const busdAbi = require("../abi/BUSD.json");

describe("SwapTest", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function becomeCZ() {
    const cz = await hre.ethers.getImpersonatedSigner(
      "0xDFd5293D8e347dFe59E90eFd55b2956a1343963d"
    );
    const uni = await new hre.ethers.Contract(
      "0xE592427A0AEce92De3Edee1F18E0157C05861564",
      uniAbi,
      hre.ethers.provider
    ).deployed();

    const dai = await new hre.ethers.Contract(
      "0x6B175474E89094C44Da98b954EedeAC495271d0F",
      daiAbi,
      hre.ethers.provider
    ).deployed();

    const usdc = await new hre.ethers.Contract(
      "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
      usdcAbi,
      hre.ethers.provider
    ).deployed();

    const busd = await new hre.ethers.Contract(
      "0x4Fabb145d64652a948d72533023f6E7A623C7C53",
      busdAbi,
      hre.ethers.provider
    ).deployed();

    const Swapper = await hre.ethers.getContractFactory("Swapper");
    const swapper = await Swapper.deploy();
    await swapper.deployed();

    return { cz, uni, dai, usdc, busd, swapper };
  }

  describe("Deployment", function () {
    it("Should deploy contracts and allow me to become CZ", async function () {
      const { cz } = await loadFixture(becomeCZ);
      expect(cz.address).to.equal("0xDFd5293D8e347dFe59E90eFd55b2956a1343963d");
    });
  });

  describe("Swap directly with UniV3", function () {
    it("Should swap 1000 DAI for USDC", async function () {
      const { cz, uni, dai, usdc } = await loadFixture(becomeCZ);
      const balanceBefore = await dai.balanceOf(cz.address);
      const amt = hre.ethers.utils.parseUnits("1000", 18);

      const approve = await dai.connect(cz).approve(uni.address, amt);
      approve.wait();

      const swap = await uni.connect(cz).exactInputSingle({
        tokenIn: dai.address,
        tokenOut: usdc.address,
        fee: 3000,
        recipient: cz.address,
        deadline: Math.floor(Date.now() / 1000) + 600,
        amountIn: amt,
        amountOutMinimum: 0,
        sqrtPriceLimitX96: 0,
      });
      await swap.wait();

      const balanceAfter = await dai.balanceOf(cz.address);
      expect(balanceAfter).to.be.equal(balanceBefore.sub(amt));
    });

    it("Should swap 1000 DAI for BUSD", async function () {
      const { cz, uni, dai, busd } = await loadFixture(becomeCZ);

      const balanceBefore = await dai.balanceOf(cz.address);
      const amt = hre.ethers.utils.parseUnits("1", 18);

      const approve = await dai.connect(cz).approve(uni.address, amt);
      approve.wait();

      const swap = await uni.connect(cz).exactInputSingle({
        tokenIn: dai.address,
        tokenOut: busd.address,
        fee: 500,
        recipient: cz.address,
        deadline: Math.floor(Date.now() / 1000) + 600,
        amountIn: amt,
        amountOutMinimum: 0,
        sqrtPriceLimitX96: 0,
      });
      await swap.wait();

      const balanceAfter = await dai.balanceOf(cz.address);
      expect(balanceAfter).to.be.equal(balanceBefore.sub(amt));
    });
  });

  describe("Swap using Swapper contract", function () {
    it("Should swap 1000 DAI for USDC", async function () {
      const { cz, dai, usdc, swapper } = await loadFixture(becomeCZ);

      const balanceBefore = await dai.balanceOf(cz.address);
      const amt = hre.ethers.utils.parseUnits("1000", 18);

      const approve = await dai.connect(cz).approve(swapper.address, amt);
      approve.wait();

      const swap = await swapper.connect(cz).swap({
        tokenIn: dai.address,
        tokenOut: usdc.address,
        fee: 3000,
        recipient: cz.address,
        deadline: Math.floor(Date.now() / 1000) + 600,
        amountIn: amt,
        amountOutMinimum: 0,
        sqrtPriceLimitX96: 0,
      });
      await swap.wait();

      const balanceAfter = await dai.balanceOf(cz.address);
      expect(balanceAfter).to.be.equal(balanceBefore.sub(amt));
    });

    it("Should swap 1000 DAI for BUSD", async function () {
      const { cz, dai, busd, swapper } = await loadFixture(becomeCZ);

      const balanceBefore = await dai.balanceOf(cz.address);
      const amt = hre.ethers.utils.parseUnits("1000", 18);

      const approve = await dai.connect(cz).approve(swapper.address, amt);
      approve.wait();

      const swap = await swapper.connect(cz).swap({
        tokenIn: dai.address,
        tokenOut: busd.address,
        fee: 500,
        recipient: cz.address,
        deadline: Math.floor(Date.now() / 1000) + 600,
        amountIn: amt,
        amountOutMinimum: 0,
        sqrtPriceLimitX96: 0,
      });
      await swap.wait();

      const balanceAfter = await dai.balanceOf(cz.address);
      expect(balanceAfter).to.be.equal(balanceBefore.sub(amt));
    });
  });
});
