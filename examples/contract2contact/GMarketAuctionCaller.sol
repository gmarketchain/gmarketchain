// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {GMarketAuction} from "./GMarketAuction.sol";

contract GMarketAuctionCaller {

    GMarketAuction auction;

    constructor(address counterAddress) {
        auction = GMarketAuction(counterAddress);
    }

    function increment() external {
        auction.increment();
        auction.increment();
    }
}