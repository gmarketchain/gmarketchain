// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract GMarketAuction is ERC1155Holder {

    using SafeERC20 for IERC20;

    struct Lot {
        uint256 id;
        address seller;
        address marketAddress;
        uint256 itemId;
        uint256 itemCount;
        uint256 pricePerItem;
    }
    address public _owner;
    IERC20 public _token;

    uint256 public _lastLotId;
    uint256[] public _lotIds;
    address[] public _sellers;
    mapping(uint256 => Lot) public _lots;
    mapping(address => uint256[]) public _sellerLotIds;

    constructor(address tokenAddress) {
        _owner = msg.sender;
        _token = IERC20(tokenAddress);
    }

    function createLot(address marketAddress, uint256 itemId, uint256 itemCount, uint256 price) external returns (uint256) {
        return createLotInternal(marketAddress, msg.sender, itemId, itemCount, price);
    }

    function createLot(address marketAddress, address seller, uint256 itemId, uint256 itemCount, uint256 price) external returns (uint256) {
        require(_owner == msg.sender, "You are not the owner of the contract");
        return createLotInternal(marketAddress, seller, itemId, itemCount, price);
    }

    function purchaseLot(uint256 lotId) external {
        purchaseLotInternal(msg.sender, lotId);
    }

    function purchaseLot(address buyer, uint256 lotId) external {
        require(_owner == msg.sender, "You are not the owner of the contract");
        purchaseLotInternal(buyer, lotId);
    }

    function cancelLot(uint256 lotId) external {
        cancelLotInternal(msg.sender, lotId);
    }

    function cancelLot(address seller, uint256 lotId) external {
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

    function createLotInternal(address marketAddress, address seller, uint256 itemId, uint256 itemCount, uint256 pricePerItem) internal returns (uint256) {
        uint256 lotId = ++_lastLotId;
        _lotIds.push(lotId);
        _lots[lotId] = Lot({
            id: lotId,
            seller: seller,
            marketAddress: marketAddress,
            itemId: itemId,
            itemCount: itemCount,
            pricePerItem: pricePerItem
        });
        _sellerLotIds[seller].push(lotId);
        if (_sellerLotIds[seller].length == 1) {
            _sellers.push(seller);
        }
        IERC1155 market = IERC1155(marketAddress);
        market.safeTransferFrom(seller, address(this), itemId, itemCount, "");
        return lotId;
    }

    function purchaseLotInternal(address buyer, uint256 lotId) internal {
        Lot memory lot = _lots[lotId];
        require(lot.id != 0, "Lot not found");
        delete _lots[lotId];
        deleteElement(_lotIds, lotId);
        deleteElement(_sellerLotIds[lot.seller], lotId);
        if (_sellerLotIds[lot.seller].length == 0) {
            deleteElement(_sellers, lot.seller);
        }
        IERC1155 market = IERC1155(lot.marketAddress);
        market.safeTransferFrom(address(this), buyer, lot.itemId, lot.itemCount, "");
        _token.safeTransferFrom(buyer, lot.seller, lot.itemCount * lot.pricePerItem);
    }

    function cancelLotInternal(address seller, uint256 lotId) internal {
        Lot memory lot = _lots[lotId];
        require(lot.id != 0, "Lot not found");
        require(lot.seller == seller, "Wrong seller specified");
        delete _lots[lotId];
        deleteElement(_lotIds, lotId);
        deleteElement(_sellerLotIds[lot.seller], lotId);
        if (_sellerLotIds[lot.seller].length == 0) {
            deleteElement(_sellers, lot.seller);
        }
        IERC1155 market = IERC1155(lot.marketAddress);
        market.safeTransferFrom(address(this), lot.seller, lot.itemId, lot.itemCount, "");
    }

    function getLotsBySellerInternal(address seller) internal view returns (Lot[] memory) {
        return getLotsByIds(_sellerLotIds[seller]);
    }

    function getLotsByIds(uint256[] memory lotIds) internal view returns (Lot[] memory lots) {
        lots = new Lot[](lotIds.length);
        for (uint256 i = 0; i < lotIds.length; i++) {
            lots[i] = _lots[lotIds[i]];
        }
    }

    function deleteElement(uint256[] storage array, uint256 value) internal {
        if (array.length == 1 && array[0] == value) {
            array.pop();
        } else if (array.length > 1) {
            for (uint256 i = 0; i < array.length - 1; i++) {
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
            for (uint256 i = 0; i < array.length - 1; i++) {
                if (value == array[i]) {
                    array[i] = array[array.length - 1];
                    array.pop();
                }
            }
        }
    }

    function existsElement(address[] storage array, address value) internal view returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == value) {
                return true;
            }
        }
        return false;
    }
}
