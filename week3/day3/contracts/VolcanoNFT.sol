// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./VolcanoCoin.sol";

import "hardhat/console.sol";

interface IVolcanoCoin {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external;
}

contract VolcanoNFT is ERC721Enumerable, Ownable {
    uint public immutable MAX_SUPPLY = 100;
    uint public immutable ETH_PRICE = .01 ether;
    uint public immutable TOKEN_PRICE = 100;
    string public baseURI;
    bool public metadataFrozen;
    VolcanoCoin public volcanoCoin;

    constructor(address _volcanoCoin) ERC721("Volcano NFT", "VOLCANO") {
        volcanoCoin = VolcanoCoin(_volcanoCoin);
    }

    // Allow a user to mint a Volcano NFT for .01 ETH
    function mintWithETH(address to) public payable {
        require(msg.value == 0.01 ether, "Incorrect ETH value");
        require(totalSupply() < MAX_SUPPLY, "Max supply reached");
        uint mintIndex = totalSupply();
        _safeMint(to, mintIndex);
    }

    function mintWithVolcanoCoin(address to) public {
        require(
            volcanoCoin.transferFrom(msg.sender, address(this), TOKEN_PRICE),
            "Unable to transfer VolcanoCoin"
        );

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
