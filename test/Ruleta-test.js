const { expect } = require("chai");
const { ethers, web3 } = require("hardhat");

describe("Ruleta", function () {
    let Ruleta, ruleta
    beforeEach(async function () {
        [owner, addr1, addr2, addr3, addr4, addr5] = await ethers.getSigners();
        Ruleta = await ethers.getContractFactory("Ruleta");
        ruleta = await Ruleta.deploy();
        await ruleta.deployed();
        await web3.eth.sendTransaction({from: addr1.address, to: ruleta.address, value: 10000})
        ruleta.connect(addr1).placeBet(10000);
    })
    it("The contract should have funds", async function () {
        const funds = await ruleta.connect(addr1).getFunds();
        expect(funds).to.equal(10000)
    })
    it("The contract should pay to the winner", async function() {
        const funds = await ruleta.connect(addr1).getFunds();
        expect(funds).to.equal(10000)
        await ruleta.payWinner(150, addr2.address)
        const funds2 = await ruleta.connect(addr1).getFunds();
        expect(funds2).to.equal(9850)
    })
})