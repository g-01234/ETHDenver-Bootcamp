pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED

// HW8
// Updated to support foundry

import "@openzeppelin/contracts/access/Ownable.sol";

contract VolcanoCoin is Ownable {
    struct Payment {
        address recipient;
        uint amount;
    }

    uint public totalSupply = 10000;
    mapping(address => uint256) public balances;
    mapping(address => Payment[]) private payments;

    mapping(address => mapping(address => uint256)) private _allowances;

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

    function approve(address spender, uint amount) public returns (bool) {
        _allowances[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint amount
    ) public returns (bool) {
        require(spendAllowance(from, amount), "Not enough allowance");
        transfer(from, to, amount);
        return true;
    }

    function spendAllowance(address from, uint amount) internal returns (bool) {
        _allowances[from][msg.sender] -= amount;
        return true;
    }

    // Minimal safety!
    function transfer(
        address from,
        address to,
        uint amount
    ) public returns (bool) {
        balances[from] -= amount;
        balances[to] += amount;
        recordPayment(msg.sender, to, amount);
        emit TokenTransfer(msg.sender, to, amount);
        return true;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }
}
