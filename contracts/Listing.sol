// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Listing {
    struct item {
        string name;
        uint256 availableStartTime; // Timestamp when buying starts
        uint256 duration; // Duration of buying period (in seconds)
        uint256 price; // Price of the item
    }

    constructor () {}

    mapping(uint256 => item) items; // Mapping from item ID to item struct
    uint256 nextItemId; // ID to assign to the next item

    event ItemAdded(uint256 itemId, string name, uint256 availableStartTime, uint256 duration, uint256 price);

    // Function to add a new item
    function addItem(
        string memory _name,
        uint256 _availableStartTime,
        uint256 _duration,
        uint256 _price
    ) external {
        require(_availableStartTime >= block.timestamp, "Available start time must be in the future");
        require(_duration > 0, "Duration must be greater than zero");
        require(_price > 0, "Price must be greater than zero");

        items[nextItemId] = item(_name, _availableStartTime, _duration, _price);
        emit ItemAdded(nextItemId, _name, _availableStartTime, _duration, _price);
        nextItemId++;
    }

    // Function to get item details by ID
    function getItem(uint256 _itemId) external view returns (
        string memory name,
        uint256 availableStartTime,
        uint256 duration,
        uint256 price
    ) {
        require(_itemId < nextItemId, "item does not exist");

        item storage onList = items[_itemId];
        return (onList.name, onList.availableStartTime, onList.duration, onList.price);
    }
}
