// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test, console} from "forge-std/Test.sol";
import {DeterministicDeployFactory} from "../src/DeterministicDeployFactory.sol";

bytes constant CREATION_CODE = hex"7c73de0476793ff6bbf931b5fd8586e275b43be195c260005260206000f3600052601d6003f3";
uint256 constant CREATE2_SALT = 60748729702101849646808978840268289598583515997710136007149635330502551403523;
address constant CREATE2_ADDRESS = 0x931Bc39B82F30bB728a51A088aff093bBe716F6f;
address constant PLAYER = 0xDe0476793ff6BBf931B5FD8586E275B43Be195C2;

contract DeterministicDeployFactoryTest is Test {
    DeterministicDeployFactory factory;

    function setUp() public {
        factory = new DeterministicDeployFactory();
        vm.label(address(factory), "DeterministicDeployFactory");
        console.log("Created factory at", address(factory));
    }

    function getAddress(
        bytes memory bytecode,
        uint _salt,
        address _sender
    ) public view returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), _sender, _salt, keccak256(bytecode))
        );

        // NOTE: cast last 20 bytes of hash to address
        return address(uint160(uint(hash)));
    }

    function testCreate2() public {
        vm.startPrank(PLAYER, PLAYER);

        address predicted = getAddress({bytecode: CREATION_CODE, _salt: CREATE2_SALT, _sender: address(factory)});
        address predicted2 = factory.getAddress({bytecode: CREATION_CODE, _salt: CREATE2_SALT});

        address deployed = factory.deploy({bytecode: CREATION_CODE, _salt: CREATE2_SALT});

        assertEq(predicted2, deployed, "Predicted address must match deployed address");
        assertEq(deployed, CREATE2_ADDRESS, "Deployed address must match CREATE2 address");

        vm.stopPrank();
    }
}
