// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import '@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';

/// @custom:security-contact @derodero24
contract SampleNFTUpgradable is
    Initializable,
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    ERC721BurnableUpgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;

    // Sale information
    uint256 public constant MAX_SUPPLY = 10;
    uint256 public constant MINT_PRICE = 0.01 ether;

    // Metadata
    string public baseURI;

    // Royalty [%]
    uint8 public royaltyPercentage;

    CountersUpgradeable.Counter private _tokenIdCounter;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(string memory _baseURI) public initializer {
        __ERC721_init('SampleNFTUpgradable', 'SNFTU');
        __ERC721Enumerable_init();
        __ERC721Burnable_init();
        __Ownable_init();
        __UUPSUpgradeable_init();

        setBaseURI(_baseURI);
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

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    /*-----------------------------------------------------------------
        The following functions are overrides required by Solidity.
    -----------------------------------------------------------------*/

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
