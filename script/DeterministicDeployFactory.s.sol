// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {DeterministicDeployFactory} from "../src/DeterministicDeployFactory.sol";

address constant PLAYER = 0xDe0476793ff6BBf931B5FD8586E275B43Be195C2;

contract DeterministicDeployFactoryScript is Script {

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.rememberKey(privateKey);
        require(deployer == PLAYER, "Deployer must be player");

        vm.startBroadcast(deployer);

        DeterministicDeployFactory deployFactory = new DeterministicDeployFactory();

        vm.stopBroadcast();

        console.log("Deployed at:", address(deployFactory));
    }
}