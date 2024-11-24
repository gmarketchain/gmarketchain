// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GMarketAuction {

    struct Lot {
        uint id;
        address seller;
        string itemId;
        uint price;
    }

    uint private _nextLotId;

    mapping(uint => Lot) public _lots;

    function createLot(string memory itemId, uint price) external returns (uint) {
        uint lotId = _nextLotId++;
        Lot memory lot;
        lot.id = lotId;
        lot.seller = msg.sender;
        lot.itemId = itemId;
        lot.price = price;
        _lots[lotId] = lot;
        return lotId;
    }

    function get(uint lotId) external view returns (Lot memory) {
        return _lots[lotId];
    }
}