pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED

contract VolcanoCoin {
    struct Payment {
        address recipient;
        uint amount;
    }

    uint public totalSupply = 10000;
    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => Payment[]) public payments;

    event SupplyIncrease(uint newSupply);
    event TokenTransfer(address from, address to, uint amount);

    constructor() {
        owner = msg.sender;
        balances[owner] = totalSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner!");
        _;
    }

    // Don't really need this, compiler makes a totalSupply() fn for us
    function getTotalSupply() public view returns (uint) {
        return totalSupply;
    }

    function increaseTotalSupply() public onlyOwner {
        totalSupply += 1000;
        balances[owner] += 1000; // Give it to the owner
        emit SupplyIncrease(totalSupply);
    }

    // minimal safety
    function transfer(address to, uint amount) public returns (bool) {
        balances[msg.sender] -= amount;
        balances[to] += amount;
        payments[msg.sender].push(Payment(to, amount));
        emit TokenTransfer(msg.sender, to, amount);
        return true;
    }
}
