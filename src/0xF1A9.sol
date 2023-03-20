// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IPuzzle} from "curta/interfaces/IPuzzle.sol";
import {CREATE3} from "solmate/utils/CREATE3.sol";

/// @title 0xF1A9
/// @author fiveoutofnine
contract F1A9 is
    IPuzzle // 0x9f00c43700bc0000Ff91bE00841F8e04c0495000
{
    event Bool(bool _value);
    event Bytes4(bytes4 _value);

    /// @inheritdoc IPuzzle
    function name() external pure returns (string memory) {
        return "0xF1A9";
    }

    /// @inheritdoc IPuzzle
    function generate(address _seed) external view returns (uint256) {
        return (uint256(uint160(_seed)) >> (((block.number >> 8) & 0x1F) << 2)) & 0xFFFF;
    }

    /// @inheritdoc IPuzzle
    function verify(uint256 _start, uint256 _solution) external returns (bool) {
        uint256 prefix = block.timestamp < 1678446000 ? (0xF1A9 << 16) | _start : 0;
        emit Bytes4(bytes4(uint32(prefix)));
        emit Bool(prefix == (_solution >> 128));
        emit Bool(ISolve(address(uint160(_solution))).curtaPlayer() == msg.sender);
        return true;
        // return prefix == (_solution >> 128) && ISolve(address(uint160(_solution))).curtaPlayer() == msg.sender;
    }
}

interface ISolve {
    function curtaPlayer() external pure returns (address);
}
