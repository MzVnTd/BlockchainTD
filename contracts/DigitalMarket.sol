// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

contract DigitalMarket {
	enum Role {Seller, Buyer, User}
	mapping(address => Role) public roles;

	enum Status {OnSale, Sold, Cancelled}

	address public contractOwner;
	uint idCounter = 1;
	uint idSale = 1;
	uint fee = 5;

	constructor() {
		contractOwner = msg.sender;
	}

	struct Product {
		uint id;
		string title;
		string compositor;
		string artist;
		string description;
		address owner;
	}
	mapping(uint => Product) public products;

	struct Sale {
		uint sale_ID;
		uint product_ID;
		uint256 price;
		address payable seller;
		address buyer;
		Status status;
	}
	mapping(uint => Sale) public sales;

	modifier isProductOwner(uint _id) {
		require(msg.sender == products[_id].owner, "UNAUTHORIZED");
		_;
	}

	modifier isOwner(uint _id) {
		require(msg.sender == sales[_id].seller, "UNAUTHORIZED");
		_;
	}

	modifier isRole(Role _role) {
		require(roles[msg.sender] == _role, "UNAUTHORIZED_ROLE");
		_;
	}

	modifier onSale(uint _id) {
		require(sales[_id].status == Status.OnSale, "THE MUSIC IS NOT ON SALE");
		_;
	}

	function setRole(Role _role) public {
		roles[msg.sender] = _role;
	}

	function incrementCounter() public returns (uint) {
		return idCounter++;
	}

	function changeFee(uint _fee) public isRole(Role.Seller) {
		fee = _fee;
	}

	function newProduct(string memory _title, string memory _compositor, string memory _artist, string memory _description) public isRole(Role.Seller) {
		products[idCounter] = Product(idCounter, _title, _compositor, _artist, _description, payable(msg.sender));
		incrementCounter();
	}

	function getProductById(uint _id) public view returns (uint id, string memory title, string memory compositor, string memory artist, string memory description, address owner) {
		require(_id < idCounter, "NOT FOUND");
		Product memory product = products[_id];
		return (product.id, product.title, product.compositor, product.artist, product.description, product.owner);
	}

	function newSale(uint _productId, uint256 _price) public isRole(Role.Seller) isProductOwner(_productId) {
		sales[idSale] = Sale(idSale, _productId, _price, payable(msg.sender), address(0), Status.OnSale);
		idSale++;
	}

	function getSaleById(uint _id) public view returns (uint id, uint productId, uint256 price, Status status) {
		require(_id < idSale, "NOT FOUND");
		Sale memory sale = sales[_id];
		return (sale.sale_ID, sale.product_ID, sale.price, sale.status);
	}

	function buy(uint _id) public payable isRole(Role.Buyer) onSale(_id) {
		Sale storage sale = sales[_id];
		Product storage product = products[sale.product_ID];
		require(msg.value >= sale.price + (sale.price * (fee/100)), "INSUFFICIENT FUNDS");

		sale.seller.transfer(sale.price);
		sale.buyer = msg.sender;
		sale.status = Status.Sold;
		product.owner = msg.sender;
		products[sale.product_ID] = product;
		sales[_id] = sale;
	}

	function cancelSale(uint _id) public isOwner(_id) onSale(_id) {
		Sale storage sale = sales[_id];
		sale.status = Status.Cancelled;
		sales[_id] = sale;
	}
}