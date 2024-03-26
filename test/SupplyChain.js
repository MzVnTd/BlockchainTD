const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Test", function() {

    it("Save", async function(){
        const [owner] = await ethers.getSigners()
        const tracking = await ethers.deployContract("Tracking");

        await tracking.connect(owner).add("Nike", "Tech");

        const product = await tracking.products(1);
        expect(product.name).to.equal("Nike");
        expect(product.description).to.equal("Tech");
    }) 
    
	it("Verify traceability", async function() {
		const [owner] = await ethers.getSigners();
		const tracking = await ethers.deployContract("Tracking");

		await tracking.connect(owner).add("Nike", "Tech");

		var product = await tracking.verifyProduct(1);
		expect(product.name).to.equal("Nike");
		expect(product.description).to.equal("Tech");
		
	})

    it("Update", async function(){
        const [owner, addr1] = await ethers.getSigners()
        const tracking = await ethers.deployContract("Tracking");

        await tracking.connect(owner).add("Nike", "Tech");

        var product = await tracking.products(1);
        expect(product.name).to.equal("Nike");
        expect(product.description).to.equal("Tech");

        await tracking.modify(1,"Adidas","Stan Smith");
        
        product = await tracking.products(1);
        expect(product.name).to.equal("Adidas");
        expect(product.description).to.equal("Stan Smith");
    })

	it("Transfer Ownership", async function(){
        const [owner, addr1] = await ethers.getSigners()
        const tracking = await ethers.deployContract("Tracking");

        await tracking.connect(owner).add("Nike", "Tech");

		var product = await tracking.products(1);
        expect(product.owner).to.equal(owner.address);

        await tracking.transferProduct(1,addr1.address, "Distributor");
        
        product = await tracking.products(1);
        expect(product.owner).to.equal(addr1.address);
    })
})