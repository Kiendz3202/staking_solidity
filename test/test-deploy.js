const { ethers } = require('hardhat');
const { assert } = require('chai');

describe('StakeMK', () => {
	let TokenContract, StakingContract, MK;
	beforeEach(async () => {
		const TokenContract = await ethers.getContractFactory('MK');
		MK = await TokenContract.deploy();
		await MK.deployed();
		console.log(MK.address);

		const StakingContract = await ethers.getContractFactory('StakeMK');
		console.log('Deploying contract....');
		const stakingContract = await StakingContract.deploy(MK.address);
		await stakingContract.deployed();
		console.log('Deployed contract to: ' + stakingContract.address);
	});

	it('Check token is created?', async () => {
		const expectedTokenSymbol = 'MK';
		const realTokenSymbol = await MK.symbol();
		assert(realTokenSymbol, expectedTokenSymbol);
	});
});
