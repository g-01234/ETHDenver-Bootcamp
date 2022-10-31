// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "hardhat/console.sol";

contract VolcanoNFT is ERC721Enumerable, Ownable {
    uint public immutable MAX_SUPPLY = 100;

    constructor() ERC721("Volcano NFT", "VOLCANO") {}

    function mint(address to) public {
        uint mintIndex = totalSupply();
        console.log(mintIndex);
        require(mintIndex < MAX_SUPPLY, "Max supply reached");
        _safeMint(to, mintIndex);
    }
}
