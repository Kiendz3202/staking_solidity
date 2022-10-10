const { ethers, run, network } = require('hardhat');

const main = async () => {
	//deploy token MK
	console.log('Deploying token MK....');
	const TokenContract = await ethers.getContractFactory('MK');
	const MK = await TokenContract.deploy();
	// await MK.deployed();
	console.log(MK.address);

	const StakingContract = await ethers.getContractFactory('StakeMK');
	console.log('Deploying contract....');
	const stakingContract = await StakingContract.deploy(MK.address);
	await stakingContract.deployed();
	console.log('Deployed contract to: ' + stakingContract.address);

	// set condition to verify
	// if (network.config.chainId === 5 && process.env.ETHERSCAN_API_KEY) {
	// 	console.log('waiting for block confirmations');
	// 	await stakingContract.deployTransaction.wait(6);
	// 	await verify(stakingContract.address, []);
	// }
};

//verify function

// const verify = async (ContractAddress, args) => {
// 	console.log('verify contract');
// 	try {
// 		run('verify:verify', {
// 			address: ContractAddress,
// 			constructorArguments: args,
// 		});
// 	} catch (error) {
// 		if (error.message.toLowerCase().includes('already verified')) {
// 			console.log('Already Verified!');
// 		} else {
// 			console.log(error);
// 		}
// 	}
// };

main()
	.then(() => process.exit(0))
	.catch((err) => {
		console.error(err);
		process.exit(1);
	});
