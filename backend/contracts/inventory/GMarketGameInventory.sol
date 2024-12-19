// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract GMarketGameInventory is ERC1155 {

    constructor() ERC1155("https://gmarket.com/api/item/{id}.json") {
        _mint(msg.sender, 1, 10000000, "");
        _mint(msg.sender, 2, 10000000, "");
        _mint(msg.sender, 3, 10000000, "");
        _mint(msg.sender, 4, 10000000, "");
    }
}
