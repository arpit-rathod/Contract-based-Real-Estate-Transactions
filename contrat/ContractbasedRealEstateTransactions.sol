// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title RealEstate - A simple marketplace for listing and buying properties
contract RealEstate {
    address public owner;

    // Represents a property listed for sale
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

    /// @notice List a new property for sale
    /// @param _price The price of the property in wei
    function listProperty(uint _price) public {
        require(_price > 0, "Price must be greater than zero");

        properties[nextPropertyId] = Property({
            id: nextPropertyId,
            seller: payable(msg.sender),
            buyer: address(0),
            price: _price,
            isSold: false
        });

        nextPropertyId++;
    }

    /// @notice Purchase a listed property
    /// @param _propertyId The ID of the property to buy
    function buyProperty(uint _propertyId) public payable {
        Property storage property = properties[_propertyId];

        require(!property.isSold, "Property has already been sold");
        require(msg.value == property.price, "Please pay the exact price");

        property.seller.transfer(msg.value);
        property.buyer = msg.sender;
        property.isSold = true;
    }

    /// @notice View details of a specific property
    /// @param _propertyId The ID of the property to view
    function getProperty(uint _propertyId) public view returns (
        uint id,
        address seller,
        address buyer,
        uint price,
        bool isSold
    ) {
        Property memory p = properties[_propertyId];
        return (p.id, p.seller, p.buyer, p.price, p.isSold);
    }

    /// @notice Cancel a property listing (only by the seller)
    /// @param _propertyId The ID of the property to cancel
    function cancelListing(uint _propertyId) public {
        Property storage property = properties[_propertyId];
        require(property.seller == msg.sender, "Only the seller can cancel this listing");
        require(!property.isSold, "Cannot cancel a sold property");

        delete properties[_propertyId];
    }

    /// @notice Get all currently unsold properties
    /// @return An array of property IDs that are still for sale
    function getUnsoldPropertyIds() public view returns (uint[] memory) {
        uint[] memory temp = new uint[](nextPropertyId);
        uint count = 0;

        for (uint i = 1; i < nextPropertyId; i++) {
            if (!properties[i].isSold) {
                temp[count] = i;
                count++;
            }
        }

        uint[] memory unsold = new uint[](count);
        for (uint j = 0; j < count; j++) {
            unsold[j] = temp[j];
        }

        return unsold;
    }

    /// @notice Get all properties listed by a specific seller
    /// @param _seller The address of the seller
    /// @return An array of property IDs listed by the given seller
    function getPropertiesBySeller(address _seller) public view returns (uint[] memory) {
        uint[] memory temp = new uint[](nextPropertyId);
        uint count = 0;

        for (uint i = 1; i < nextPropertyId; i++) {
            if (properties[i].seller == _seller) {
                temp[count] = i;
                count++;
            }
        }

        uint[] memory sellerProperties = new uint[](count);
        for (uint j = 0; j < count; j++) {
            sellerProperties[j] = temp[j];
        }

        return sellerProperties;
    }
}
