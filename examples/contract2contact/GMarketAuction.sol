// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GMarketAuction {

    uint public number;

    function increment() external {
        number += 1;
    }

    function value() external view returns (uint) {
        return number;
    }
}