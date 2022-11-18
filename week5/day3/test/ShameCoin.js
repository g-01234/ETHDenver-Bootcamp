const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("ShameCoin", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployShameCoin() {
    // Contracts are deployed using the first signer/account by default
    const [deployer, addr1, addr2] = await ethers.getSigners();

    const ShameCoin = await ethers.getContractFactory("ShameCoin");
    const shameCoin = await ShameCoin.deploy();

    return { shameCoin, deployer, addr1, addr2 };
  }

  describe("Deployment", function () {
    it("Should be deployed with an admin and 0 decimals", async function () {
      const { shameCoin, deployer } = await loadFixture(deployShameCoin);
      expect(await shameCoin.admin()).to.equal(deployer.address);
      expect(await shameCoin.decimals()).to.equal(0);
    });
  });

  describe("Transferring", function () {
    it("Should allow admin to transfer ONE token", async function () {
      const { shameCoin, deployer, addr1 } = await loadFixture(deployShameCoin);
      await shameCoin.transfer(addr1.address, 1);
      expect(await shameCoin.balanceOf(addr1.address)).to.equal(1);
      await expect(shameCoin.transfer(addr1.address, 2)).to.be.reverted;
    });

    it("Should increment their balance when non-admins try to transfer tokens", async function () {
      const { shameCoin, deployer, addr1 } = await loadFixture(deployShameCoin);
      await shameCoin.transfer(addr1.address, 1);
      await shameCoin.connect(addr1).transfer(deployer.address, 1);
      expect(await shameCoin.balanceOf(deployer.address)).to.equal(0);
      expect(await shameCoin.balanceOf(addr1.address)).to.equal(2);
    });

    it("Should just reduce balance of holder on transferFrom", async function () {
      const { shameCoin, deployer, addr1 } = await loadFixture(deployShameCoin);
      await shameCoin.transfer(addr1.address, 1);
      await shameCoin
        .connect(addr1)
        .transferFrom(addr1.address, deployer.address, 1);

      expect(await shameCoin.balanceOf(deployer.address)).to.equal(0);
      expect(await shameCoin.balanceOf(addr1.address)).to.equal(0);
    });
  });

  describe("Approvals", function () {
    it("Should allow non-admins to approve admin to spend one token", async function () {
      const { shameCoin, deployer, addr1, addr2 } = await loadFixture(
        deployShameCoin
      );
      await shameCoin.transfer(addr1.address, 1);
      await shameCoin.connect(addr1).approve(deployer.address, 1);
      expect(
        await shameCoin.allowance(addr1.address, deployer.address)
      ).to.equal(1);
      await expect(shameCoin.connect(addr1).approve(addr2.address, 1)).to.be
        .reverted;
    });
  });
});
