import {ethers} from "hardhat";

const main = async () => {
    const ListingFactory = await ethers.getContractFactory("Listing");
    const ListingContract = await ListingFactory.deploy();
    const ListingContractAddress = await ListingContract.getAddress();

    console.log("Listing Contract Address: ", ListingContractAddress);
}

main();