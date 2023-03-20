// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test, console} from "forge-std/Test.sol";

contract EmptyFunctionTest is Test {
    function setUp() public {
        console.log("EmptyFunctionTest.setUp()");
    }

    function testEmpty() public {
        function () _withdraw;
        console.log("EmptyFunctionTest.testEmpty()");
        
        vm.expectRevert();
        _withdraw(); 
    }
}