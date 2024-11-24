// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GMarketAuction {

    struct Lot {
        uint id;
        address seller;
        string itemId;
        uint price;
    }

    uint public _lastLotId;
    uint[] public _lotIds;
    address[] public _sellers;
    mapping(uint => Lot) public _lots;
    mapping(address => uint[]) public _sellerLotIds;

    function createLot(string memory itemId, uint price) external returns (uint) {
        uint lotId = ++_lastLotId;
        _lotIds.push(lotId);
        _lots[lotId] = Lot({id: lotId, seller: msg.sender, itemId: itemId, price: price});
        _sellerLotIds[msg.sender].push(lotId);
        if (_sellerLotIds[msg.sender].length == 1) {
            _sellers.push(msg.sender);
        }
        return lotId;
    }

    function cancelLot(uint lotId) external returns (bool) {
        Lot memory lot = _lots[lotId];
        if (lot.id == 0) {
            return false;
        }
        if (lot.seller != msg.sender) {
            return false;
        }
        delete _lots[lotId];
        deleteElement(_lotIds, lotId);
        deleteElement(_sellerLotIds[msg.sender], lotId);
        if (_sellerLotIds[msg.sender].length == 0) {
            deleteElement(_sellers, msg.sender);
        }
        return true;
    }

    function getAllLots() external view returns (Lot[] memory) {
        Lot[] memory lots = new Lot[](_lotIds.length);
        for (uint i = 0; i < _lotIds.length; i++) {
            lots[i] = _lots[_lotIds[i]];
        }
        return lots;
    }

    function getMyLots() external view returns (Lot[] memory) {
        uint[] memory lotIds = _sellerLotIds[msg.sender];
        Lot[] memory lots = new Lot[](lotIds.length);
        for (uint i = 0; i < lotIds.length; i++) {
            lots[i] = _lots[lotIds[i]];
        }
        return lots;
    }

    function getAllSellers() external view returns (address[] memory) {
        uint[] memory lotIds = _sellerLotIds[msg.sender];
        address[] memory sellers = new address[](lotIds.length);
        for (uint i = 0; i < lotIds.length; i++) {
            sellers[i] = _lots[lotIds[i]].seller;
        }
        return sellers;
    }

    function deleteElement(uint[] storage array, uint value) internal returns (bool) {
        if (array.length == 1 && array[0] == value) {
            array.pop();
            return true;
        } else if (array.length > 1) {
            for (uint i = 0; i < array.length - 1; i++) {
                if (value == array[i]) {
                    array[i] = array[array.length - 1];
                    array.pop();
                    return true;
                }
            }
        }
        return false;
    }

    function deleteElement(address[] storage array, address value) internal returns (bool) {
        if (array.length == 1 && array[0] == value) {
            array.pop();
            return true;
        } else if (array.length > 1) {
            for (uint i = 0; i < array.length - 1; i++) {
                if (value == array[i]) {
                    array[i] = array[array.length - 1];
                    array.pop();
                    return true;
                }
            }
        }
        return false;
    }
}
