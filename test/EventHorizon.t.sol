// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {IPuzzle} from "curta/interfaces/IPuzzle.sol";
import {ICurta} from "curta/interfaces/ICurta.sol";
import {EventHorizon} from "../src/EventHorizon.sol";

contract EventHorizonTest is Test {
    uint32 constant PUZZLE_ID = 6;
    uint256 constant PUZZLE_SOLUTION_GAS_LIMIT = 911874;
    uint256 constant CURTA_SOLUTION_GAS_LIMIT = 955488;
    uint256 constant SOLUTION_START = 1 << 255;

    ICurta curta = ICurta(0x0000000006bC8D9e5e9d436217B88De704a9F307);
    IPuzzle puzzle = IPuzzle(0x58c5d6154cb30f9b6A9E23e733BDD1EAb4e2c14d);
    // EventHorizon puzzle = new EventHorizon();

    address internal player = 0xDe0476793ff6BBf931B5FD8586E275B43Be195C2;
    uint256 internal start = 0x3dc677f228fbc8123fb836778519daabfaf06a13dc9aefe6509cf28700000f15; // 27941747318843799895449077486581058335115694333924107088705808354461521809173
    // only 0x12c74d33 is valid
    uint256 forkId;

    function setUp() public {
        string memory url = vm.envString("FOUNDRY_ETH_RPC_URL");
        vm.createSelectFork(url, 16975654);
        vm.label(address(curta), "curta");
        vm.label(address(puzzle), "puzzle");

        vm.label(player, "player");
        vm.startPrank(player, player);

        // // puzzle = new EventHorizon();
        // // vm.label(address(puzzle), "puzzle");

        // // start = puzzle.generate(player);

        // // console.log("start: %x", start);
    }

    // @dev Helper test to generate a correct gas limit for the puzzle in order to receive a seed with five zeros
    function testGenerateCorrectGasLimit() public {
        for (uint256 gasLimit = 200000; gasLimit < 2000000;) {
            uint256 seed = puzzle.generate{gas: gasLimit}({_seed: player});

            if (seed & 0xfffff000 == 0) {
                console.log(gasLimit);
                console.logBytes32(bytes32(seed));
                break;
            }
            unchecked {
                ++gasLimit;
            }
        }
    }

    // @dev Test we have generated the correct seed using our found gas limit
    function testCorrectSeedOnPuzzle() public {
        uint256 seed = puzzle.generate{gas: PUZZLE_SOLUTION_GAS_LIMIT}({_seed: player});
        assertEq(start, seed, "seed is not correct");
    }

    // @dev We need to increase PUZZLE_SOLUTION_GAS_LIMIT by the gas used in the Curta contract
    // In my case it was by 43614, I found it out by simulating in Tenderly, because it is easier than with foundry
    function testGenerateCorrectSolution() public {
        for (uint256 solution = SOLUTION_START; solution < SOLUTION_START + 1000000;) {
            vm.expectRevert();
            if (puzzle.verify{gas: CURTA_SOLUTION_GAS_LIMIT}(start, solution)) {
                console.log("solution: %x", solution);
                break;
            }

            unchecked {
                ++solution;
            }
        }
    }

    // @dev Test we have generated the correct solution using our found gas limit
    function testSolution() public {
        assertTrue(
            puzzle.verify{gas: CURTA_SOLUTION_GAS_LIMIT}(
                start, 0x80000000000000000000000000000000000000000000000000000000000002ed
            )
        );
    }
}
