require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-web3");

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();
  for (const account of accounts) {
    console.log(account.address);
  }
});
// task action function receives the Hardhat Runtime Environment as second argument
task("accountsweb3", "Prints accounts", async (_, { web3 }) => {
  console.log(await web3.eth.getAccounts());
});
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.0",
  networks: {
    hardhat: {
      chainId: 1337
    },
  }
};
