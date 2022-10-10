require('@nomicfoundation/hardhat-toolbox');
require('dotenv').config();
require('@nomiclabs/hardhat-etherscan');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
	solidity: '0.8.17',
	defaultNetwork: 'hardhat',
	networks: {
		localhost: {
			url: 'http://127.0.0.1:8545/',
			chainId: 31337,
		},
		goerli: {
			url: process.env.GOERLI_RPC_URL,
			chainId: 5,
			accounts: [process.env.PRIVATE_KEY],
		},
	},
	etherscan: {
		apiKey: process.env.ETHERSCAN_API_KEY,
	},
};
