const { ethers } = require('hardhat');
const { assert } = require('chai');

describe('StakeMK', () => {
	let stakingContract, MK, deployer, user1;
	beforeEach(async () => {
		[deployer, user1] = await ethers.getSigners();

		const TokenContract = await ethers.getContractFactory('MK');
		MK = await TokenContract.deploy();
		await MK.deployed();
		console.log(MK.address);

		const StakingContract = await ethers.getContractFactory('StakeMK');
		console.log('Deploying contract....');
		stakingContract = await StakingContract.deploy(MK.address);
		await stakingContract.deployed();
		console.log('Deployed contract to: ' + stakingContract.address);
	});

	it('Check token is created?', async () => {
		const expectedTokenSymbol = 'MK';
		const realTokenSymbol = await MK.symbol();
		assert(realTokenSymbol, expectedTokenSymbol);
	});

	it('Check transfer token', async () => {
		const initUser1Token = await MK.balanceOf(user1.address);
		await MK.transfer(user1.address, 200000);
		const finalUser1Token = await MK.balanceOf(user1.address);
		assert(finalUser1Token, initUser1Token + 200000);
	});

	it('Check staking', async () => {
		// await MK.connect(deployer).approve(stakingContract.address, 1000000);
		await MK.transfer(stakingContract.address, 100000);

		await MK.transfer(user1.address, 100000);
		await MK.connect(user1).approve(stakingContract.address, 100000);

		const initTokenUser1 = await MK.balanceOf(user1.address);
		const initTokenStaking = await MK.balanceOf(stakingContract.address);

		await stakingContract.connect(user1).stakeToken(1000);
		await ethers.provider.send('evm_increaseTime', [31 * 24 * 60 * 60]);

		const finalTokenUser1 = await MK.balanceOf(user1.address);
		const finalTokenStaking = await MK.balanceOf(stakingContract.address);

		assert(initTokenUser1, finalTokenUser1 - 1500);
		assert(initTokenStaking, finalTokenStaking + 1500);

		await stakingContract.connect(user1).claimReward();
		const totalToken = await MK.balanceOf(user1.address);
		const tokenReward = totalToken - 100000;

		assert(tokenReward, 300);

		const tokenStakingContractAfterRewarded = await MK.balanceOf(
			stakingContract.address
		);
		assert(tokenStakingContractAfterRewarded, initTokenStaking - 300);
	});
});
