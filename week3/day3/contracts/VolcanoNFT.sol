// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

// Question 3: Allowing the owner to change the metadata URI could result in
// a compromised owner changing the metadata URI to a malicious URI. However,
// NFT projects frequently include a "reveal", where the owner sets a new URI.
// I implemented a "freeze" function that prevents the owner from changing the
// metadata URI once the bool is set.

contract VolcanoNFT is ERC721Enumerable, Ownable {
    uint public immutable MAX_SUPPLY = 100;
    string public baseURI;
    bool public metadataFrozen;

    constructor() ERC721("Volcano NFT", "VOLCANO") {}

    // Allow a user to mint a Volcano NFT for .01 ETH
    function mintWithETH(address to) public payable {
        require(msg.value == 0.01 ether, "Incorrect ETH value");
        require(totalSupply() < MAX_SUPPLY, "Max supply reached");
        uint mintIndex = totalSupply();
        _safeMint(to, mintIndex);
    }

    // Allow the owner to set the base URI as long as metadata is not frozen
    function setBaseURI(string memory _baseURI) public onlyOwner {
        require(!metadataFrozen, "Metadata is frozen");
        baseURI = _baseURI;
    }

    // TokenURI is a function that returns the URI of the token
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, Strings.toString(tokenId)))
                : "";
    }

    // Allow the owner to freeze the metadata URI
    function freezeMetadata() public onlyOwner {
        metadataFrozen = true;
    }

    function withdraw() public onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Transfer failed.");
    }
}
