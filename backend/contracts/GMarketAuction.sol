// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GMarketAuction {

    struct Lot {
        uint id;
        address seller;
        string itemId;
        uint price;
    }

    address public _owner;
    uint public _lastLotId;
    uint[] public _lotIds;
    address[] public _sellers;
    mapping(uint => Lot) public _lots;
    mapping(address => uint[]) public _sellerLotIds;

    constructor() {
        _owner = msg.sender;
    }

    function createLot(string memory itemId, uint price) external returns (uint) {
        return createLotInternal(msg.sender, itemId, price);
    }

    function createLot(address seller, string memory itemId, uint price) external returns (uint) {
        require(_owner == msg.sender, "You are not the owner of the contract");
        return createLotInternal(seller, itemId, price);
    }

    function cancelLot(uint lotId) external {
        cancelLotInternal(msg.sender, lotId);
    }

    function cancelLot(address seller, uint lotId) external {
        require(_owner == msg.sender, "You are not the owner of the contract");
        cancelLotInternal(seller, lotId);
    }

    function getMyLots() external view returns (Lot[] memory) {
        return getLotsBySellerInternal(msg.sender);
    }

    function getLotsBySeller(address seller) external view returns (Lot[] memory) {
        require(_owner == msg.sender, "You are not the owner of the contract");
        return getLotsBySellerInternal(seller);
    }

    function getLots() external view returns (Lot[] memory) {
        return getLotsByIds(_lotIds);
    }

    function getSellers() external view returns (address[] memory) {
        return _sellers;
    }

    function createLotInternal(address seller, string memory itemId, uint price) internal returns (uint) {
        uint lotId = ++_lastLotId;
        _lotIds.push(lotId);
        _lots[lotId] = Lot({id: lotId, seller: seller, itemId: itemId, price: price});
        _sellerLotIds[seller].push(lotId);
        if (_sellerLotIds[seller].length == 1) {
            _sellers.push(seller);
        }
        return lotId;
    }

    function cancelLotInternal(address seller, uint lotId) internal {
        Lot memory lot = _lots[lotId];
        require(lot.id != 0, "Lot not found");
        require(lot.seller == seller, "Wrong seller specified");
        delete _lots[lotId];
        deleteElement(_lotIds, lotId);
        deleteElement(_sellerLotIds[msg.sender], lotId);
        if (_sellerLotIds[msg.sender].length == 0) {
            deleteElement(_sellers, msg.sender);
        }
    }

    function getLotsBySellerInternal(address seller) internal view returns (Lot[] memory) {
        return getLotsByIds(_sellerLotIds[seller]);
    }

    function getLotsByIds(uint[] memory lotIds) internal view returns (Lot[] memory lots) {
        lots = new Lot[](lotIds.length);
        for (uint i = 0; i < lotIds.length; i++) {
            lots[i] = _lots[lotIds[i]];
        }
    }

    function deleteElement(uint[] storage array, uint value) internal {
        if (array.length == 1 && array[0] == value) {
            array.pop();
        } else if (array.length > 1) {
            for (uint i = 0; i < array.length - 1; i++) {
                if (value == array[i]) {
                    array[i] = array[array.length - 1];
                    array.pop();
                }
            }
        }
    }

    function deleteElement(address[] storage array, address value) internal {
        if (array.length == 1 && array[0] == value) {
            array.pop();
        } else if (array.length > 1) {
            for (uint i = 0; i < array.length - 1; i++) {
                if (value == array[i]) {
                    array[i] = array[array.length - 1];
                    array.pop();
                }
            }
        }
    }
}
