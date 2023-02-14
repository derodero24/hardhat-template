import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { expect } from 'chai';
import { ethers, upgrades } from 'hardhat';

import type { SampleNFTUpgradable } from '../typechain-types';

describe('SampleNFTUpgradable', () => {
  async function deploy() {
    const [owner, other1, other2] = await ethers.getSigners();

    const baseURI = 'ipfs://abc/';
    const royaltyPercentage = 10;

    const contract = await ethers
      .getContractFactory('SampleNFTUpgradable')
      .then(factory =>
        upgrades.deployProxy(factory, [baseURI, royaltyPercentage], {
          kind: 'uups',
        }),
      )
      .then(contract => contract.deployed())
      .then(contract => contract as SampleNFTUpgradable);

    return {
      contract,
      baseURI,
      royaltyPercentage,
      owner: owner!,
      other1: other1!,
      other2: other2!,
    };
  }

  describe('Base information', () => {
    it('Right name & symbol', async () => {
      const { contract } = await loadFixture(deploy);
      expect(await contract.name()).to.equal('SampleNFTUpgradable');
      expect(await contract.symbol()).to.equal('SNFTU');
    });

    it('Right owner address', async () => {
      const { contract, owner } = await loadFixture(deploy);
      expect(await contract.owner()).to.equal(owner.address);
    });

    it('Right owner max supply', async () => {
      const { contract } = await loadFixture(deploy);
      expect(await contract.MAX_SUPPLY()).to.equal(10);
    });

    it('Right owner mint price', async () => {
      const { contract } = await loadFixture(deploy);
      expect(await contract.MINT_PRICE()).to.equal(
        ethers.utils.parseEther('0.01'),
      );
    });
  });

  describe('Minting', () => {
    it('Mint by owner', async () => {
      const { contract, owner } = await loadFixture(deploy);
      await contract.ownerMint();
      expect(await contract.balanceOf(owner.address)).to.equal(1);
      expect(await contract.totalSupply()).to.equal(1);
    });

    it('Mint by others', async () => {
      const { contract, other1, other2 } = await loadFixture(deploy);
      const MINT_PRICE = await contract.MINT_PRICE();
      await contract.connect(other1).mint({ value: MINT_PRICE });
      await contract.connect(other2).mint({ value: MINT_PRICE });
      await contract.connect(other2).mint({ value: MINT_PRICE });
      expect(await contract.balanceOf(other1.address)).to.equal(1);
      expect(await contract.balanceOf(other2.address)).to.equal(2);
      expect(await contract.totalSupply()).to.equal(3);
    });

    it('Mint by others with wrong msg.value', async () => {
      // TODO
    });

    it('Mint limit', async () => {
      // TODO
    });
  });

  describe('Token URI', () => {
    it('Right initial token URI', async () => {
      const { contract, baseURI } = await loadFixture(deploy);
      expect(await contract.tokenURI(1)).to.equal(`${baseURI}1.json`);
      expect(await contract.tokenURI(23)).to.equal(`${baseURI}23.json`);
    });

    it('Update token URI', async () => {
      // TODO
    });
  });

  describe('Burn', () => {
    it('', async () => {
      // TODO
    });
  });

  describe('Royalty', () => {
    it('Right initial royality info', async () => {
      const { contract, royaltyPercentage, owner } = await loadFixture(deploy);

      // pattern 1
      const [receiver, royaltyAmount] = await contract.royaltyInfo(1, 10_000);
      expect(receiver).to.equal(owner.address);
      expect(royaltyAmount).to.equal(10_000 * (royaltyPercentage / 100));

      // pattern 2
      const [receiver2, royaltyAmount2] = await contract.royaltyInfo(23, 123);
      expect(receiver2).to.equal(owner.address);
      expect(royaltyAmount2).to.equal(
        Math.floor(123 * (royaltyPercentage / 100)),
      );
    });

    it('Update royality percentage', async () => {
      // TODO
    });
  });

  describe('Only owner', () => {
    it('', async () => {
      // TODO
    });
  });

  // it('Right total supply', async  () => {
  //   const { contract } = await loadFixture(deploy);
  //   expect(await contract.totalSupply()).to.equal(10000);
  // });

  // it('Deployment should assign the total supply of tokens to the owner', async  () => {
  //   const { contract, owner } = await loadFixture(deploy);
  //   const balance = await contract.balanceOf(owner.address);

  //   expect(await contract.totalSupply()).to.equal(balance);
  // });

  // it('Transfer 50 tokens from owner to other1', async  () => {
  //   const { contract, owner, other1 } = await loadFixture(deploy);

  //   await expect(contract.transfer(other1.address, 50)).to.changeTokenBalances(
  //     contract,
  //     [owner, other1],
  //     [-50, 50],
  //   );
  // });

  // it('Transfer 50 tokens from owner to other1 to other2', async  () => {
  //   const { contract, owner, other1, other2 } = await loadFixture(deploy);

  //   await expect(contract.transfer(other1.address, 50)).to.changeTokenBalances(
  //     contract,
  //     [owner, other1],
  //     [-50, 50],
  //   );
  //   await expect(
  //     contract.connect(other1).transfer(other2.address, 50),
  //   ).to.changeTokenBalances(contract, [other1, other2], [-50, 50]);
  // });

  // it('should emit Transfer events', async  () => {
  //   const { contract, owner, other1, other2 } = await loadFixture(deploy);

  //   await expect(contract.transfer(other1.address, 50))
  //     .to.emit(contract, 'Transfer')
  //     .withArgs(owner.address, other1.address, 50);
  //   await expect(contract.connect(other1).transfer(other2.address, 50))
  //     .to.emit(contract, 'Transfer')
  //     .withArgs(other1.address, other2.address, 50);
  // });

  // it("Should fail if sender doesn't have enough tokens", async  () => {
  //   const { contract, owner, other1 } = await loadFixture(deploy);
  //   const initialOwnerBalance = await contract.balanceOf(owner.address);

  //   await expect(
  //     contract.connect(other1).transfer(owner.address, 1),
  //   ).to.be.revertedWith('Not enough tokens');
  //   expect(await contract.balanceOf(owner.address)).to.equal(
  //     initialOwnerBalance,
  //   );
  // });
});
