// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title RealEstate - A simple marketplace for listing and buying properties using Ethereum
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
    function buyProperty(uint _propertyId) public payable {
        Property storage property = properties[_propertyId];

        require(!property.isSold, "Property has already been sold");
        require(msg.value == property.price, "Please pay the exact price");

        property.seller.transfer(msg.value);
        property.buyer = msg.sender;
        property.isSold = true;
    }

    /// @notice View details of a specific property
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

    /// @notice Cancel a property listing (only the original seller can cancel)
    function cancelListing(uint _propertyId) public {
        Property storage property = properties[_propertyId];
        require(property.seller == msg.sender, "Only the seller can cancel this listing");
        require(!property.isSold, "Cannot cancel a sold property");

        delete properties[_propertyId];
    }

    /// @notice Get IDs of all unsold properties
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

    /// @notice Get all property IDs listed by a specific seller
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

    // ---------------------------------------------------------
    // 🔥 Added 5 Human-written useful functions below
    // ---------------------------------------------------------

    /// @notice Check if a property is available for purchase
    function isAvailable(uint _propertyId) public view returns (bool) {
        Property memory property = properties[_propertyId];
        return !property.isSold && property.price > 0;
    }

    /// @notice Get the total number of properties listed
    function getTotalProperties() public view returns (uint) {
        return nextPropertyId - 1;
    }

    /// @notice Get the owner (seller) address of a property
    function getSellerOfProperty(uint _propertyId) public view returns (address) {
        return properties[_propertyId].seller;
    }

    /// @notice Update the price of an unsold property (only seller can update)
    function updatePropertyPrice(uint _propertyId, uint _newPrice) public {
        Property storage property = properties[_propertyId];
        require(property.seller == msg.sender, "Only the seller can update the price");
        require(!property.isSold, "Cannot update price after sale");
        require(_newPrice > 0, "New price must be greater than zero");

        property.price = _newPrice;
    }

    /// @notice Allows contract owner to withdraw accidental ETH sent to contract
    function withdrawEther() public {
        require(msg.sender == owner, "Only contract owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }

}
