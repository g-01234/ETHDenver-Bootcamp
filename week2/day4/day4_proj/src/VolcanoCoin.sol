pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED

// HW8
// Updated to support foundry

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract VolcanoCoin is Ownable {
    struct Payment {
        address recipient;
        uint amount;
    }

    uint public totalSupply = 10000;
    mapping(address => uint256) public balances;
    mapping(address => Payment[]) private payments;

    address public _owner;

    event SupplyIncrease(uint newSupply);
    event TokenTransfer(address from, address to, uint amount);

    constructor() {
        balances[owner()] = totalSupply;
    }

    function getPaymentsForUser(address user)
        public
        view
        returns (Payment[] memory)
    {
        return payments[user];
    }

    function getTotalSupply() public view returns (uint) {
        return totalSupply;
    }

    function increaseTotalSupply() public onlyOwner {
        totalSupply += 1000;
        balances[owner()] += 1000; // Give it to the owner
        emit SupplyIncrease(totalSupply);
    }

    function recordPayment(
        address from,
        address to,
        uint amount
    ) internal {
        payments[from].push(Payment(to, amount));
    }

    // Minimal safety!
    function transfer(address to, uint amount) public returns (bool) {
        balances[msg.sender] -= amount;
        balances[to] += amount;
        recordPayment(msg.sender, to, amount);
        emit TokenTransfer(msg.sender, to, amount);
        return true;
    }
}
