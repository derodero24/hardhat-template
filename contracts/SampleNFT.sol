// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol';
import '@openzeppelin/contracts/token/common/ERC2981.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import 'operator-filter-registry/src/DefaultOperatorFilterer.sol';

/// @custom:security-contact @derodero24
contract SampleNFT is
    ERC721,
    ERC721Enumerable,
    ERC721Burnable,
    ERC2981,
    Ownable,
    DefaultOperatorFilterer
{
    using Counters for Counters.Counter;

    // Sale information
    uint256 public constant MAX_SUPPLY = 10;
    uint256 public constant MINT_PRICE = 0.01 ether;

    // Metadata
    string public baseURI;

    Counters.Counter private _tokenIdCounter;

    constructor(string memory _baseURI, uint96 _royaltyPercentage)
        ERC721('SampleNFT', 'SNFT')
    {
        setBaseURI(_baseURI);
        setRoyaltyPercentage(_royaltyPercentage);
    }

    /*----------
        Mint
    ----------*/

    function _mint(address _to) internal {
        // Check total supply
        require(totalSupply() < MAX_SUPPLY, 'Max supply reached.');

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(_to, tokenId);
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

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(baseURI, Strings.toString(_tokenId), '.json')
            );
    }

    /*-------------
        Royalty
    -------------*/

    function setRoyaltyPercentage(uint96 _royaltyPercentage) public onlyOwner {
        // Convert _royaltyPercentage to between 0 and 10_000.
        _setDefaultRoyalty(owner(), _royaltyPercentage * 100);
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
        override(ERC721, ERC721Enumerable, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /*------------------------------
        Operator Filter Registry
    ------------------------------*/

    function setApprovalForAll(address operator, bool approved)
        public
        override(ERC721, IERC721)
        onlyAllowedOperatorApproval(operator)
    {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId)
        public
        override(ERC721, IERC721)
        onlyAllowedOperatorApproval(operator)
    {
        super.approve(operator, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721, IERC721) onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721, IERC721) onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public override(ERC721, IERC721) onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, data);
    }
}
