//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NftMarketPlace {
    struct Listing {
        uint256 price;
        address seller;
    }

    event ItemListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    error NftMarketPlace__PriceMustBeAboveZero();
    error NftMarketPlace__NotApprovedForMarketplace();
    error NftMarketPlace__NotListed(address nftAddress, uint256 tokenId);
    error NftMarketPlace__AlreadyListed(address nftAddress, uint256 tokenId);
    error NftMarketPlace__NotOwner();

    mapping(address => mapping(uint256 => Listing)) listings$;

    modifier isListed(address nftAddress, uint256 tokenId) {
        Listing memory listing = listings$[nftAddress][tokenId];
        if (listing.price <= 0) {
            revert NftMarketPlace__NotListed(nftAddress, tokenId);
        }
        _;
    }

    modifier notListed(
        address nftAddress,
        uint256 tokenId,
        address owner
    ) {
        Listing memory listing = listings$[nftAddress][tokenId];
        if (listing.price > 0) {
            revert NftMarketPlace__AlreadyListed(nftAddress, tokenId);
        }
        _;
    }

    modifier isOwner(
        address nftAddress,
        uint256 tokenId,
        address spender
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (spender != owner) {
            revert NftMarketPlace__NotOwner();
        }
        _;
    }

    /**
     * @notice Method for listing your NFT on the marketplace
     * @param nftAddress: Address of the NFT
     * @param tokenId: Token ID of the NFT
     * @param price: Price of the NFT
     * @dev Owner still keeps their NFT until it is being bought
     */
    function listItem(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    )
        external
        notListed(nftAddress, tokenId, msg.sender)
        isOwner(nftAddress, tokenId, msg.sender)
    {
        if (price <= 0) {
            revert NftMarketPlace__PriceMustBeAboveZero();
        }
        IERC721 nft = IERC721(nftAddress);
        if (nft.getApproved(tokenId) != address(this)) {
            revert NftMarketPlace__NotApprovedForMarketplace();
        }
        listings$[nftAddress][tokenId] = Listing(price, msg.sender);
        emit ItemListed(msg.sender, nftAddress, tokenId, price);
    }

    function buyItem(
        address nftAddress,
        uint256 tokenId
    ) external payable isListed(nftAddress, tokenId) {}
}

// - `buyItem`: Buy a NFT
// - `cancelItem`: Cancel a listing
// - `updateListing`: Update Price
// - `withdrawProceeds`: Withdraw payment for my bought NFTs
