// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/VolcanoCoin.sol";

contract VolcanoTest is Test {
    VolcanoCoin public vc;

    function setUp() public {
        vc = new VolcanoCoin();
    }

    function testTotalSupply() public {
        assertEq(vc.getTotalSupply(), 10000);
    }

    function testIncreaseSupply() public {
        vc.increaseTotalSupply();
        assertEq(vc.getTotalSupply(), 11000);
    }

    function testIncreaseAsNotOwner() public {
        vm.expectRevert();
        vm.prank(address(0));
        vc.increaseTotalSupply();
    }
}
