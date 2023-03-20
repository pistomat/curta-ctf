// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test, console2} from "forge-std/Test.sol";
import {IPuzzle} from "curta/interfaces/IPuzzle.sol";
import {TwoTimesFourIsEight} from "../src/TwoTimesFourIsEight.sol";

contract PuzzleSolver is Test {
    IPuzzle puzzle;

    // uint256 start;

    function setUp() public {
        puzzle = new TwoTimesFourIsEight();

        // start = puzzle.generate(address(this));
    }

    function testSolution(uint256 solution) public {
        assertEq(puzzle.verify(26331588094111276903890636024121443185624100028900007699143458816, solution), false);
    }

    function testSolutionTrue() public {
        assertEq(puzzle.verify(26331588094111276903890636024121443185624100028900007699143458816, 8767697537775521018336954041039440183220111646253115682672234792762092893543), true);
    }
}