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
        address gameInventoryAddress;
        uint256 itemId;
        uint256 itemCount;
        uint256 pricePerItem;
    }

    address public _owner;
    IERC20 public _coin;

    uint256 public _lastLotId;
    uint256[] public _lotIds;
    mapping(uint256 => Lot) public _lots;

    constructor(address coinAddress) {
        _owner = msg.sender;
        _coin = IERC20(coinAddress);
    }

    function createLot(
        address gameInventoryAddress,
        uint256 itemId,
        uint256 itemCount,
        uint256 pricePerItem
    ) external returns (uint256) {
        return _createLot(gameInventoryAddress, msg.sender, itemId, itemCount, pricePerItem);
    }

    function purchaseLot(uint256 lotId) external {
        _purchaseLot(msg.sender, lotId);
    }

    function cancelLot(uint256 lotId) external {
        _cancelLot(msg.sender, lotId);
    }

    function getLots() external view returns (Lot[] memory lots) {
        lots = new Lot[](_lotIds.length);
        for (uint256 i = 0; i < _lotIds.length; i++) {
            lots[i] = _lots[_lotIds[i]];
        }
    }

    function _createLot(
        address gameInventoryAddress,
        address seller,
        uint256 itemId,
        uint256 itemCount,
        uint256 pricePerItem
    ) internal returns (uint256 lotId) {
        lotId = ++_lastLotId;
        _lotIds.push(lotId);
        _lots[lotId] = Lot({
            id: lotId,
            seller: seller,
            gameInventoryAddress: gameInventoryAddress,
            itemId: itemId,
            itemCount: itemCount,
            pricePerItem: pricePerItem
        });
        IERC1155 gameInventory = IERC1155(gameInventoryAddress);
        gameInventory.safeTransferFrom(seller, address(this), itemId, itemCount, "");
    }

    function _purchaseLot(address buyer, uint256 lotId) internal {
        Lot memory lot = _lots[lotId];
        require(lot.id != 0, "Lot not found");
        delete _lots[lotId];
        _deleteElement(_lotIds, lotId);
        IERC1155 gameInventory = IERC1155(lot.gameInventoryAddress);
        gameInventory.safeTransferFrom(address(this), buyer, lot.itemId, lot.itemCount, "");
        _coin.safeTransferFrom(buyer, lot.seller, lot.itemCount * lot.pricePerItem);
    }

    function _cancelLot(address seller, uint256 lotId) internal {
        Lot memory lot = _lots[lotId];
        require(lot.id != 0, "Lot not found");
        require(lot.seller == seller, "Wrong seller specified");
        delete _lots[lotId];
        _deleteElement(_lotIds, lotId);
        IERC1155 gameInventory = IERC1155(lot.gameInventoryAddress);
        gameInventory.safeTransferFrom(address(this), lot.seller, lot.itemId, lot.itemCount, "");
    }

    function _deleteElement(uint256[] storage array, uint256 value) internal {
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
}
