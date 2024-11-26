// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IGMarketInventory} from "./IGMarketInventory.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract GMarketInventory is IGMarket, ERC1155 {

    constructor() ERC1155("https://game.example/api/item/{id}.json") {
        _mint(msg.sender, 1, 1, "");
    }
}