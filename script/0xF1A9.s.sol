// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {F1A9, ISolve} from "../src/0xF1A9.sol";
import {Curta} from "curta/Curta.sol";
import {DeterministicDeployFactory} from "../src/DeterministicDeployFactory.sol";

bytes constant CREATION_CODE = hex"7c730000000006bc8d9e5e9d436217b88de704a9f30760005260206000f3600052601d6003f3";
address constant DEPLOY_FACTORY = 0xcFd687Bd0844104b2BFc0bC23ED52ab3E2d6C94b;
uint256 constant CREATE2_SALT = uint256(bytes32(0x2cbcdef96a7474d0f183279878ae4d15968aa361a703a9e0f5fee9c3b9981b79));
F1A9 constant PUZZLE = F1A9(0x9f00c43700bc0000Ff91bE00841F8e04c0495000);
address constant PLAYER = 0xDe0476793ff6BBf931B5FD8586E275B43Be195C2;
Curta constant CURTA = Curta(0x0000000006bC8D9e5e9d436217B88De704a9F307);

contract F1A9Script is Script {
    // F1A9 public PUZZLE;

    error PuzzleVerifyFailed();

    function setUp() public {
        // PUZZLE = new F1A9();

        vm.label(address(PUZZLE), "PUZZLE");
        vm.label(DEPLOY_FACTORY, "DEPLOY_FACTORY");
        vm.label(PLAYER, "PLAYER");
        vm.label(address(CURTA), "CURTA");
    }

    function run() public {
        console.log("Block number:", block.number, "mod256:", block.number % 256);
        console.log("Block timestamp:", block.timestamp);

        uint256 _start = PUZZLE.generate(PLAYER);
        console.log("Solution start:", _start);
        console.logBytes2(bytes2(uint16(_start)));

        uint256 prefix = block.timestamp < 1678446000 ? (0xF1A9 << 16) | _start : 0;

        console.log("Solution prefix:", prefix);
        console.logBytes4(bytes4(uint32(prefix)));

        console.log("Creation code:");
        console.logBytes(CREATION_CODE);
        console.log("CREATE2 salt:", CREATE2_SALT);

        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.rememberKey(privateKey);
        require(deployer == PLAYER, "Deployer must be player");

        DeterministicDeployFactory deployFactory = DeterministicDeployFactory(DEPLOY_FACTORY);

        vm.startBroadcast(deployer);
        // address deployed = 0xF1A967932C4b7510C2262CFBB00F489F6F46Bdc7;
        address deployed = deployFactory.deploy({_salt: CREATE2_SALT, bytecode: CREATION_CODE});

        vm.stopBroadcast();
        vm.startPrank(deployer);
        vm.label(deployed, "DEPLOYED");

        bytes4 deployedPrefix = bytes4(bytes20(deployed));
        console.log("Solution deployed at: ", deployed);
        console.logBytes4(deployedPrefix);

        uint256 solution = uint256(uint160(deployed));
        console.log("Solution:", solution);
        address _solution = address(uint160(solution));
        console.log("Solution address:", _solution);

        address curtaPlayer = ISolve(_solution).curtaPlayer();
        console.log("Curta player:", curtaPlayer);

        require(curtaPlayer == address(CURTA), "Player must be player");

        CURTA.solve(2, solution);
        console.log("Solution verified!", solution);

        vm.stopPrank();
    }
}
