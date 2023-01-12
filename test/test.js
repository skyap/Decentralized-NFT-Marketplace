const { ethers } = require("hardhat");
const { expect } = require("chai");


describe("Router",()=>{
    let factoryContract,routerContract,collectionContract;
    let cowbuy,producer,investor;
    before("Deploy Factory and Router",async()=>{
        [cowbuy,producer,investor] = await ethers.getSigners();
        // console.log(await producer.getBalance());
        const factory = await ethers.getContractFactory("NFTMarketplaceFactory");
        factoryContract = await factory.connect(cowbuy).deploy();
        console.log("factoryContract Address",factoryContract.address);
        const router = await ethers.getContractFactory("NFTMarketplaceRouter");
        routerContract = await router.connect(cowbuy).deploy(factoryContract.address);
        console.log("routerContract Address",routerContract.address);
    });
    it("Check owner of router contract same as cowbuy",async ()=>{
        expect(cowbuy.address).to.equal(await routerContract.cowbuy());
    });

    it("Check factory address in router contract same as deployed factory address",async()=>{
        expect(factoryContract.address).to.equal(await routerContract.factoryAddress());
    })
    it("Create collection and check owner of collection contract",async()=>{
        await routerContract.connect(producer).createCollection(
            500,
            1000,
            5000,
            "contractURI",
            "baseURI",
            "name",
            "symbol"
            );

        // console.log((await routerContract.collections(0)).collectionCreator,producer.address);
        expect((await routerContract.collections(0)).collectionCreator).to.equal(producer.address);
    
    });
    it("Check owner of collection contract",async()=>{
        const collectionAddress = (await routerContract.collections(0)).collectionAddress;
        const collectionContract = await ethers.getContractAt("ITree",collectionAddress);
        console.log(await collectionContract.owner());
        // console.log(collectionAddress);
        // console.log(await collectionContract.getUnMintSellingPrice(0));
    });
    it("Update token prices",async()=>{
        // console.log(await routerContract.collections(0));
    });
    it("Mint NFT with payable");
    it("Payout release and NFT burn");

});