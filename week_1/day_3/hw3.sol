// SPDX-License-Identifier: None

pragma solidity 0.8.17;

contract BootcampContract {
    uint256 number;
    address deployer;

    constructor(address _deployer) {
        deployer = _deployer;
    }

    function fetchAddr() external view returns (address) {
        if (msg.sender == deployer) {
            return address(0x000000000000000000000000000000000000dEaD);
        } else {
            return deployer;
        }
    }

    function store(uint256 num) public {
        number = num;
    }

    function retrieve() public view returns (uint256) {
        return number;
    }
}
