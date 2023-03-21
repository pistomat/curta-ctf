// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {ITinySolve} from "../src/ITinySolve.sol";
import {IPuzzle} from "curta/interfaces/IPuzzle.sol";
import {ICurta} from "curta/interfaces/ICurta.sol";

// TinySig constant PUZZLE = TinySig(0x9f00c43700bc0000Ff91bE00841F8e04c0495000);
address constant PLAYER = 0xDe0476793ff6BBf931B5FD8586E275B43Be195C2;
ICurta constant CURTA = ICurta(0x0000000006bC8D9e5e9d436217B88De704a9F307);
ITinySolve constant TINYSOLVE = ITinySolve(0x000000000045E5418329Ee1F6D07Dc6E73ad0AB0);
IPuzzle constant PUZZLE = IPuzzle(0x54430C6aa52325479eE4F1d432346DE08F011bDb);
uint32 constant _puzzleId = 3;

address constant SIGNER = 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf;

uint256 constant _start = 31507307859246979739374794109012539555897628806597578132969923113009969317218; // 0x45a8811907fd65c04c718943c33d54a1bed7fc23a1de2852fec9439bb4c74562
uint256 constant _solution = 39973814025812092804909412448744877187869633737260819893120014820871315128320; // 0x586060808280806e45e5418329ee1f6d07dc6e73ad0ab05afa5090f300000000

bytes32 constant h = 0xdd2bbf737c014d1fd9c73b22a592ff6e51a1f140c963e1e9936025e87c73022d;
uint8 constant v = 28;
bytes32 constant r = 0x00000000000000000000003b78ce563f89a0ed9414f5aa28ad0d96d6795f9c63;
bytes32 constant s = bytes32(_start); // 0x45a8811907fd65c04c718943c33d54a1bed7fc23a1de2852fec9439bb4c74562

contract TinySigScript is Script {
    event Transfer(address indexed from, address indexed to, uint256 indexed id);
    event SolvePuzzle(uint32 indexed id, address indexed solver, uint256 solution, uint8 phase);

    function setUp() public {
        vm.label(address(PUZZLE), "PUZZLE");
        vm.label(PLAYER, "PLAYER");
        vm.label(address(CURTA), "CURTA");
    }

    function run() public {
        vm.startBroadcast(PLAYER);

        address addr = ecrecover(h, v, r, s);
        require(addr == SIGNER, "SIGNER check");

        TINYSOLVE.setHash({_hash: h});

        vm.expectEmit(true, true, false, false);
        emit Transfer({from: address(0), to: address(PLAYER), id: 1});

        vm.expectEmit(true, true, true, false);
        emit SolvePuzzle({id: _puzzleId, solver: address(PLAYER), solution: _solution, phase: 1});

        CURTA.solve({_puzzleId: _puzzleId, _solution: _solution});

        require(CURTA.hasSolvedPuzzle({_puzzleId: _puzzleId, _solver: address(PLAYER)}), "CURTA.hasSolvedPuzzle");

        vm.stopBroadcast();
    }
}
