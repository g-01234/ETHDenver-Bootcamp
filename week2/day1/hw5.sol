pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED

// Updated with OZ ownable rather than home-cooked

import "@openzeppelin/contracts/access/Ownable.sol";

contract VolcanoCoin is Ownable {
    struct Payment {
        address recipient;
        uint amount;
    }

    uint public totalSupply = 10000;
    mapping(address => uint256) public balances;
    mapping(address => Payment[]) public payments;
    address public _owner;

    event SupplyIncrease(uint newSupply);
    event TokenTransfer(address from, address to, uint amount);

    constructor() {
        _owner = owner();
        balances[_owner] = totalSupply;
    }

    function getTotalSupply() public view returns (uint) {
        return totalSupply;
    }

    function increaseTotalSupply() public onlyOwner {
        totalSupply += 1000;
        balances[owner()] += 1000; // Give it to the owner
        emit SupplyIncrease(totalSupply);
    }

    // Minimal safety!
    function transfer(address to, uint amount) public returns (bool) {
        balances[msg.sender] -= amount;
        balances[to] += amount;
        payments[msg.sender].push(Payment(to, amount));
        emit TokenTransfer(msg.sender, to, amount);
        return true;
    }
}
