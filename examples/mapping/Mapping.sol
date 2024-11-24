// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Mapping {

    mapping(string => string) public myMap;

    function put(string memory key, string memory value) external {
        myMap[key] = value;
    }

    function get(string memory key) external view returns (string memory) {
        return myMap[key];
    }
}