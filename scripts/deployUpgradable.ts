import { ethers, upgrades } from 'hardhat';

async function main() {
  const baseURI = 'ipfs://abc/';

  // Deploying
  const instance = await ethers
    .getContractFactory('SampleNFTUpgradable')
    .then(factory => upgrades.deployProxy(factory, [baseURI], { kind: 'uups' }))
    .then(contract => contract.deployed())
    .then(contract => {
      console.log('Deployed to:', contract.address);
      return contract;
    });

  // Upgrading
  await ethers
    .getContractFactory('SampleNFTUpgradable')
    .then(factory => upgrades.upgradeProxy(instance.address, factory))
    .then(contract => contract.deployed())
    .then(contract => {
      console.log('Upgrade', contract.address);
      return contract;
    });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
