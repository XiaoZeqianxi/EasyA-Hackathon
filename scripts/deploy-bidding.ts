import {ethers} from "hardhat";

const main = async () => {
    const BiddingFactory = await ethers.getContractFactory("Bidding");
    const BiddingContract = await BiddingFactory.deploy();
    const BiddingContractAddress = await BiddingContract.getAddress();

    console.log("Bidding Contract Address: ", BiddingContractAddress);
}

main();