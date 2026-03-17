# Minimal NFT Marketplace

A professional-grade, flat-structured NFT Marketplace. This repository provides the core logic for listing and purchasing ERC721 tokens without the overhead of complex proxy patterns.

## Features
* **Atomic Transactions:** Securely swap ETH for NFTs in a single transaction.
* **Gas Optimized:** Minimal storage writes to keep listing and buying costs low.
* **Compatibility:** Works with any standard OpenZeppelin-based ERC721 token.
* **Flat Structure:** All logic contained in the root for rapid deployment and auditing.

## How it Works
1. **Approve:** The NFT owner calls `approve()` on the NFT contract, giving this marketplace permission to transfer the token.
2. **List:** Owner calls `listNft(nftAddress, tokenId, price)`.
3. **Buy:** A buyer calls `buyNft(nftAddress, tokenId)` and sends the required ETH.
4. **Cancel:** Owners can remove their listings at any time before a sale.

## Security
Includes ReentrancyGuard to prevent common exploit vectors in marketplace logic.
