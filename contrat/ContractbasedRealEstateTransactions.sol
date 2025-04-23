// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RealEstate {
    address public owner;

    struct Property {
        uint id;
        address payable seller;
        address buyer;
        uint price;
        bool isSold;
    }

    uint public nextPropertyId = 1;
    mapping(uint => Property) public properties;

    constructor() {
        owner = msg.sender;
    }

    function listProperty(uint _price) public {
        require(_price > 0, "Price must be greater than 0");

        properties[nextPropertyId] = Property({
            id: nextPropertyId,
            seller: payable(msg.sender),
            buyer: address(0),
            price: _price,
            isSold: false
        });

        nextPropertyId++;
    }

    function buyProperty(uint _propertyId) public payable {
        Property storage property = properties[_propertyId];
        require(!property.isSold, "Property already sold");
        require(msg.value == property.price, "Incorrect payment amount");

        property.seller.transfer(msg.value);
        property.buyer = msg.sender;
        property.isSold = true;
    }
}
