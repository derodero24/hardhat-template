// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/utils/Strings.sol';

/// @custom:security-contact @derodero24
contract SampleNFT is ERC721, ERC721Enumerable, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    // Sale information
    uint256 public constant MAX_SUPPLY = 10;
    uint256 public constant MINT_PRICE = 0.01 ether;

    // Metadata
    string public baseURI;

    // Royalty [%]
    uint8 public royaltyPercentage;

    Counters.Counter private _tokenIdCounter;

    constructor(string memory _baseURI) ERC721('SampleNFT', 'SNFT') {
        setBaseURI(_baseURI);
        // setRoyaltyPercentage(_royaltyPercentage);
    }

    /*----------
        Mint
    ----------*/

    function _mint(address to) internal {
        // Check total supply
        require(totalSupply() < MAX_SUPPLY, 'Max supply reached.');

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function ownerMint() public onlyOwner {
        _mint(owner());
    }

    function mint() external payable {
        // Check msg.value
        require(msg.value >= MINT_PRICE, 'msg.value is too low.');

        _mint(msg.sender);
    }

    /*---------------
        Token URI
    ---------------*/

    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(baseURI, Strings.toString(tokenId), '.json')
            );
    }

    /*-----------------------------------------------------------------
        The following functions are overrides required by Solidity.
    -----------------------------------------------------------------*/

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}