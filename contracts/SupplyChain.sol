// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

contract Tracking {
	enum Role {Producer, Distributor, Retailer, Consumer}
	uint productId = 1;

	struct Product {
		uint id;
		string name;
		string description;
		address owner;
		Role role;
		string[] locations;
	}
	mapping(uint => Product) public products;
	mapping(address => Role) public roles;

	modifier isOwner(uint _productId) {
		require(msg.sender == products[_productId].owner, "UNAUTHORIZED");
		_;
	}

	modifier isRole(Role _role) {
		require(roles[msg.sender] == _role, "UNAUTHORIZED_ROLE");
		_;
	}

	function add(string memory _name, string memory _description) public isRole(Role.Producer) {
		products[productId] = Product(productId, _name, _description, msg.sender, Role.Producer, new string[](0));
		productId++;
	}

	function modify(uint _productId, string memory _name, string memory _description) public isOwner(_productId) {
		Product memory currentProduct = products[_productId];
		currentProduct.name = _name;
		currentProduct.description = _description;
		products[_productId] = currentProduct;
	}

		function updateStatus(uint _productId, string memory _locations) private isOwner(_productId) {
		Product storage product = products[_productId];
		require(product.id != 0, "");
		
		product.role = Role(uint(product.role)+1);
		product.locations.push(_locations);
		products[_productId] = product;
	}

	function transferProduct(uint _productId, address _newOwner, string memory _locations) public isOwner(_productId) {
		Product storage product = products[_productId];
		//require(Role(uint(product.role)+1) == roles[_newOwner], "");

		updateStatus(_productId, _locations);

		product.owner = _newOwner;
		products[_productId] = product;
	}

	function verifyProduct(uint _productId) public view returns(
		string memory name, string memory description, address currentOwner , Role currentRole, string[] memory locations
		) {
		Product memory product = products[_productId];
		return (product.name, product.description, product.owner, product.role, product.locations);
	}

}