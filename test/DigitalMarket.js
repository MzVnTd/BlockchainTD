const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Digital Marketplace", function () {

	it("Create Product", async function () {
		const [owner] = await ethers.getSigners()
		const supply = await ethers.deployContract("DigitalMarket");

		await supply.connect(owner).newProduct("All the single ladies", "Beyonce", "Beyonce", "Boumboumshakoushakou");
		const product = await supply.products(1)
		expect(product.title).to.equal("All the single ladies")
		expect(product.artist).to.equal("Beyonce")
		expect(product.compositor).to.equal("Beyonce")
		expect(product.description).to.equal("Boumboumshakoushakou")
	})

	it("Create Sale", async function () {
		const [owner] = await ethers.getSigners()
		const supply = await ethers.deployContract("DigitalMarket");

		await supply.connect(owner).newProduct("Blue Bird", "Pelleck", "Pelleck", "NarutoShippuden3");
		await supply.connect(owner).newSale(1, 357608193);
		const sale = await supply.sales(1)
		console.log(sale)
		expect(sale.product_ID).to.equal(1)
		expect(sale.price).to.equal(357608193)
	})

	it("Retrieve", async function () {
		const [owner] = await ethers.getSigners();
		const marketplace = await ethers.deployContract("DigitalMarket");

		await marketplace.connect(owner).newProduct("Gangnam Style", "Psy", "Psy", "Korean music");
		await marketplace.connect(owner).newSale(1, 10);

		var product = await marketplace.getProductById(1);
		var sale = await marketplace.getSaleById(1);
		console.log(product);
		expect(product.title).to.equal("Gangnam Style");

		console.log(sale);
		expect(sale.price).to.equal(10);

	})

	it("Buy Item", async function () {
		const [owner, buyer] = await ethers.getSigners()

		const marketplace = await ethers.deployContract("DigitalMarket");

		await marketplace.connect(owner).newProduct("Gangnam Style", "Psy", "Psy", "Korean music");
		await marketplace.connect(owner).newSale(1, 1);

		product = await marketplace.products(1);
		expect(product.owner).to.equal(owner.address);

		await marketplace.connect(buyer).setRole(1);

		await marketplace.connect(buyer).buy(1, {value: ethers.parseUnits("100", "gwei")});

		product = await marketplace.products(1);
		expect(product.owner).to.equal(buyer.address);
	})
})