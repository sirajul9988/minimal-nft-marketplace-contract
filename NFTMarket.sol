// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title NFTMarket
 * @dev Simple marketplace for buying and selling ERC721 tokens for Native ETH.
 */
contract NFTMarket is ReentrancyGuard, Ownable {
    struct Listing {
        address seller;
        uint256 price;
    }

    // Mapping from NFT Contract -> Token ID -> Listing
    mapping(address => mapping(uint256 => Listing)) private s_listings;

    event ItemListed(address indexed seller, address indexed nftAddress, uint256 indexed tokenId, uint256 price);
    event ItemCanceled(address indexed seller, address indexed nftAddress, uint256 indexed tokenId);
    event ItemBought(address indexed buyer, address indexed nftAddress, uint256 indexed tokenId, uint256 price);

    constructor() Ownable(msg.sender) {}

    function listNft(address nftAddress, uint256 tokenId, uint256 price) external {
        require(price > 0, "Price must be above zero");
        IERC721 nft = IERC721(nftAddress);
        require(nft.getApproved(tokenId) == address(this) || nft.isApprovedForAll(msg.sender, address(this)), "Not approved for marketplace");
        require(nft.ownerOf(tokenId) == msg.sender, "Not the owner");

        s_listings[nftAddress][tokenId] = Listing(msg.sender, price);
        emit ItemListed(msg.sender, nftAddress, tokenId, price);
    }

    function cancelListing(address nftAddress, uint256 tokenId) external {
        Listing memory listing = s_listings[nftAddress][tokenId];
        require(listing.seller == msg.sender, "Not the seller");
        delete s_listings[nftAddress][tokenId];
        emit ItemCanceled(msg.sender, nftAddress, tokenId);
    }

    function buyNft(address nftAddress, uint256 tokenId) external payable nonReentrant {
        Listing memory listedItem = s_listings[nftAddress][tokenId];
        require(listedItem.price > 0, "Item not listed");
        require(msg.value >= listedItem.price, "Insufficient ETH sent");

        delete s_listings[nftAddress][tokenId];
        
        IERC721(nftAddress).safeTransferFrom(listedItem.seller, msg.sender, tokenId);
        
        (bool success, ) = payable(listedItem.seller).call{value: msg.value}("");
        require(success, "Transfer to seller failed");

        emit ItemBought(msg.sender, nftAddress, tokenId, listedItem.price);
    }

    function getListing(address nftAddress, uint256 tokenId) external view returns (Listing memory) {
        return s_listings[nftAddress][tokenId];
    }
}
