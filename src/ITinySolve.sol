// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface ITinySolve {
    function hashes(address) external view returns (bytes32);
    function setHash(bytes32 _hash) external;
}
