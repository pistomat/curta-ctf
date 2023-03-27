// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {LibString} from "solady/utils/LibString.sol";
import {IPuzzle} from "curta/interfaces/IPuzzle.sol";
import {WhatAreBuckets} from "../src/WhatAreBuckets.sol";

struct BfsInput {
    uint256 state;
    uint8[] ops;
}

contract WhatAreBucketsSolver is Test {
    WhatAreBuckets puzzle;

    address internal player = 0xDe0476793ff6BBf931B5FD8586E275B43Be195C2;
    uint256 internal start;

    mapping(uint256 => bool) internal stateSeen;

    mapping(uint256 => BfsInput) queue;

    uint256 first = 1;
    uint256 last = 0;

    function seen(BfsInput memory data) internal view returns (bool) {
        return stateSeen[data.state];
    }

    function notEmpty() public view returns (bool) {
        return last >= first;
    }

    function enqueue(BfsInput memory data) public {
        last += 1;
        queue[last] = data;
    }

    function dequeue() public returns (BfsInput memory data) {
        require(notEmpty(), "queue is empty");

        data = queue[first];

        delete queue[first];
        first += 1;
    }

    function opsToString(uint8[] memory ops) internal pure returns (string memory) {
        string memory str = "";
        for (uint256 i = 0; i < ops.length; i++) {
            str = string.concat(str, LibString.toString(ops[i]), " ");
        }
        return str;
    }

    function opsToCommands(uint8[] memory ops) internal pure returns (uint256) {
        uint256 commands = 0;
        for (uint256 i = 0; i < ops.length; i++) {
            // reverse of uint8(commands >> (i * 3)) & 7
            commands |= uint256(ops[i]) << (i * 3);
        }
        return commands;
    }

    function bfs(uint256 state) public returns (BfsInput memory input) {
        uint8[6] memory ops_enum = [0, 1, 2, 3, 4, 6];

        uint8[] memory ops = new uint8[](0);
        BfsInput memory root = BfsInput(state, ops);

        enqueue(root);

        while (notEmpty()) {
            BfsInput memory data = dequeue();

            if (data.state & 0xffff == 1) {
                console.log("state %x", data.state);
                console.log("solution %s", opsToString(data.ops));
                console.log("commands %x", opsToCommands(data.ops));

                return data;
            }

            for (uint8 i = 0; i < 6; i++) {
                uint8 op = ops_enum[i];
                uint256 newState = puzzle.work(data.state, op);

                if (stateSeen[newState]) continue;
                stateSeen[newState] = true;

                uint8[] memory newCommands = new uint8[](data.ops.length + 1);
                for (uint256 j = 0; j < data.ops.length; j++) {
                    newCommands[j] = data.ops[j];
                }
                newCommands[data.ops.length] = op;
                BfsInput memory child = BfsInput(newState, newCommands);
                enqueue(child);
            }
        }
    }

    function setUp() public {
        vm.label(player, "player");

        puzzle = new WhatAreBuckets();
        vm.label(address(puzzle), "puzzle");

        start = puzzle.generate(player);
    }

    function testSolution() public {
        BfsInput memory endState = bfs(start);

        uint256 commands = opsToCommands(endState.ops);
        uint256 solution = commands ^ uint256(keccak256(abi.encodePacked(start)));

        console.log(
            string.concat(
                "address: ",
                LibString.toHexStringChecksumed(address(puzzle)),
                "start: ",
                LibString.toString(start),
                " solution: ",
                LibString.toHexString(solution)
            )
        );

        assertTrue(puzzle.verify({_start: start, _solution: solution}), "solution is not valid");

        console.log("end");
    }
}
