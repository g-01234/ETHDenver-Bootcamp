// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

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

    string public baseSVG =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 256 256'>";

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

    function getColor(
        uint256 tokenId,
        uint8 x,
        uint8 y
    ) internal view returns (string memory) {
        bytes3 colorb3 = bytes3(
            keccak256(abi.encodePacked(tokenId, x, y, block.timestamp))
        );

        return string(abi.encodePacked("#", iToHex(colorb3)));
    }

    function iToHex(bytes3 buffer) internal pure returns (string memory) {
        // Fixed buffer size for hexadecimal convertion
        bytes memory converted = new bytes(buffer.length * 2);

        bytes memory _base = "0123456789abcdef";

        for (uint256 i = 0; i < buffer.length; i++) {
            converted[i * 2] = _base[uint8(buffer[i]) / _base.length];
            converted[i * 2 + 1] = _base[uint8(buffer[i]) % _base.length];
        }
        return string(converted);
    }

    function generateSvg(uint256 tokenId) public view returns (string memory) {
        string memory svg = baseSVG;

        for (uint8 x = 0; x < 8; x++) {
            for (uint8 y = 0; y < 8; y++) {
                svg = string(
                    abi.encodePacked(
                        svg,
                        "<rect x='",
                        Strings.toString(x * 8),
                        "' y='",
                        Strings.toString(y * 8),
                        "' width='8' height='8' fill='",
                        getColor(tokenId, x, y),
                        "'/>"
                    )
                );
            }
        }
        svg = string(abi.encodePacked(svg, "</svg>"));
        return svg;
    }

    // Return metadata directly
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        // require(
        //     _exists(tokenId),
        //     "ERC721Metadata: URI query for nonexistent token"
        // );

        string memory name = string(
            abi.encodePacked("#", Strings.toString(tokenId))
        );
        string memory description = "SVG Fun";
        string memory image = generateSvg(tokenId);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name":"',
                        name,
                        '", "description":"',
                        description,
                        '", "image_data":"',
                        image,
                        '"}'
                    )
                )
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
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
