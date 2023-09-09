//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract NftMarketPlace {
    error NftMarketPlace__PriceMustBeAboveZero();

    function listItem(address nft, uint256 tokenId, uint256 price) external {
        if (price <= 0) {
            revert NftMarketPlace__PriceMustBeAboveZero();
        }
    }
}

//- `listItem`: List NFTs on the marketplace
// - `buyItem`: Buy a NFT
// - `cancelItem`: Cancel a listing
// - `updateListing`: Update Price
// - `withdrawProceeds`: Withdraw payment for my bought NFTs
