// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract OrangeGus is ERC721, ERC721Enumerable, Ownable {
    using SafeERC20 for IERC20;

    IERC20 public selToken;
    uint256 public constant MINTING_INTERVAL = 24 hours;
    uint256 public lastMintTimestamp;
    uint256 public currentTokenId;
    uint256 public highestBid;
    address public highestBidder;
    bool public isBidding;

    event NewBid(address indexed bidder, uint256 amount);
    event NFTMinted(address indexed winner, uint256 tokenId);
    event NFTBurned(uint256 tokenId);

    constructor(address _selTokenAddress) ERC721("OrangeGus", "OGUS") Ownable(msg.sender) {
        selToken = IERC20(_selTokenAddress);
        lastMintTimestamp = block.timestamp;
    }

    function placeBid(uint256 _bidAmount) external {
        require(isBidding, "Bidding is not active");
        require(_bidAmount > highestBid, "Bid must be higher than current highest bid");

        if (highestBidder != address(0)) {
            // Refund the previous highest bidder
            selToken.safeTransfer(highestBidder, highestBid);
        }

        // Transfer the new bid amount from the bidder
        selToken.safeTransferFrom(msg.sender, address(this), _bidAmount);

        highestBid = _bidAmount;
        highestBidder = msg.sender;

        emit NewBid(msg.sender, _bidAmount);
    }

    function mintAndDistribute() external {
        require(block.timestamp >= lastMintTimestamp + MINTING_INTERVAL, "Minting interval not reached");
        
        lastMintTimestamp = block.timestamp;
        currentTokenId++;

        if (highestBidder != address(0)) {
            _safeMint(highestBidder, currentTokenId);
            emit NFTMinted(highestBidder, currentTokenId);

            // Burn the SEL tokens
            selToken.transfer(address(0xdead), highestBid);
        } else {
            // Burn the NFT if there were no bids
            emit NFTBurned(currentTokenId);
        }

        // Reset bidding state
        highestBid = 0;
        highestBidder = address(0);
        isBidding = false;
    }

    function startBidding() external onlyOwner {
        require(!isBidding, "Bidding is already active");
        isBidding = true;
    }

    function stopBidding() external onlyOwner {
        require(isBidding, "Bidding is not active");
        isBidding = false;
    }

    // Override required function
    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    // Override required function
    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    // Override required function
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}