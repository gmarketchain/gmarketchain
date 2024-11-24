// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Callee} from "./Callee.sol";

contract Caller {

    Callee auction;

    constructor(address counterAddress) {
        auction = Callee(counterAddress);
    }

    function increment() external {
        auction.increment();
        auction.increment();
    }
}