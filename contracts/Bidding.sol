// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Bidding {
    address public owner;
    address public highestBidder;
    uint256 public highestBid;
    uint256 public auctionEnd;
    address payable public receiverAddr;
    uint256 reservePrice;
    string massage = "Deal!";

    mapping(address => uint) pendingReturns;
    bool ended;

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);
    event Message(string massage);

    modifier onlyOwner() {
        require(msg.sender == owner, 'Only the owner can call this function');
        _;
    }

    constructor () {
        owner = msg.sender;
        auctionEnd = block.timestamp + 86400; // Default bidding time is set to 1 day (86400 seconds)
        receiverAddr = payable(address(0)); // Set receiver address to null address
        reservePrice = 0; // Default reserve price is set to 0
        minimumStartPrice = 0; // Set minimum start price to 0
        minimumIncrement = 0; // Set minimum increment to 0
    }

    // Function to update variables
    function updateVariables(uint256 _biddingTime, address payable _receiverAddr, uint256 _reservePrice, uint256 _minimumStartPrice, uint256 _minimumIncrement) external {
        require(msg.sender == owner, "Only the owner can call this function");
        auctionEnd = block.timestamp + _biddingTime;
        receiverAddr = _receiverAddr;
        reservePrice = _reservePrice;
        minimumStartPrice = _minimumStartPrice;
        minimumIncrement = _minimumIncrement;
    }

    uint256 minimumStartPrice; // Declare as state variables instead of constants
    uint256 minimumIncrement;


    /// The auction has already ended.
    error AuctionAlreadyEnded();
    /// There is already a higher or equal bid.
    error BidNotHighEnough(uint256 highestBid);
    /// The auction has not ended yet.
    error AuctionNotYetEnded();
    /// The function auctionEnd has already been called.
    error AuctionEndAlreadyCalled();
    /// The highest bid does not reach reserve price. The auction is cancelled.
    error PriceIsNoSufficient(uint256 highestBid);


    function bid(uint256 _bid) external payable {
        require(!ended, "Auction is closed");
        require(_bid > 0, "Bidding price must be larger than 0");
        require(block.timestamp < auctionEnd, "Auction already ended");
        require(_bid > highestBid, "Your bid must exceed the current highest bid");
        require(highestBidder != msg.sender, "You cannot outbid yourself");
        require(msg.sender != receiverAddr, "Seller cannot bid");

        // Check if the bid meets the minimum starting bidding price
        require(_bid >= minimumStartPrice, "Bid must be equal to or higher than the minimum starting bidding price");

        // Check if the bid meets the minimum bidding increment
        if (highestBid > 0) {
            require(_bid - highestBid >= minimumIncrement, "Bid must exceed the current highest bid by at least the minimum increment");
        }

        // If there was a previous highest bid, increase the pending return for the previous bidder
        if (highestBid > 0) {
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = _bid;

        emit HighestBidIncreased(msg.sender, highestBid);
    }


     /// Withdraw a bid that was overbid.
    function withdraw() external returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            if (!payable(msg.sender).send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionEnding() external {
        require(!ended, "Auction has already ended");
        require(block.timestamp >= auctionEnd, "Auction has not ended yet");

        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        if (ended == true && highestBid < reservePrice) {
            revert PriceIsNoSufficient(highestBid);
        } else if (ended == true && highestBid >= reservePrice) {
            receiverAddr.transfer(highestBid);
            emit Message(massage);
        }
    }
}
