// SPDX-License-Identifier: GPL-3.0
// solidity momos
pragma solidity >=0.8.0 <0.10.0;

contract contractMomos 
{
    // Might use this one day, but not today
    // address public minter;

    /* declarations (no memory usage) */
    struct Gift {
        address payable sender;
        address payable claimer;
        uint256 creationDate;
        uint amount;
        bool redeemed;
        bool refunded;
    }

    mapping (bytes32=>Gift) public gifts;

    event GiftCreated(address indexed from, uint amount, bytes32 indexed giftId, uint256 expireDate);
    event GiftRedeemed(address indexed to, uint amount, bytes32 indexed giftId);
    event GiftRefunded(address indexed from, uint amount, bytes32 indexed giftId);


    /* se ejecutará cuando se deploye el contrato */
    // constructor() {
    //     minter = msg.sender;   
    // }

    function claimGift(bytes32 hashedToken) external payable {
        require(hashedToken.length > 0, "WHAT DID WE SAY ABOUT EMPTY TOKENS, you can't claim anything without one");
        Gift storage gift = gifts[hashedToken];
        require (gift.sender != address(0), "This gift doesn't exist!");
        require (!gift.redeemed, "Gift already claimed.");
        require (!gift.refunded || block.timestamp <= gift.creationDate + 60 minutes, "This gift expired a while (or long) ago.");

        gift.redeemed = true;
        gift.claimer = payable(msg.sender);

        (bool success, ) = msg.sender.call{value: gift.amount}("");
        require (success, "An error has ocurred and you couldn't claim the gift");
        emit GiftRedeemed(msg.sender, gift.amount, hashedToken);

    }

    function createGift(bytes32 hashedToken) external payable {
        require(msg.value > 0, "why are youtrying to send a empty gift?");
        require(hashedToken.length > 0, "Secret phrase cannot be empty! You sure wanna do this without one?...");
        Gift storage existingGift = gifts[hashedToken];
        require(existingGift.sender == address(0) || existingGift.redeemed || existingGift.refunded, "Secret phrase already in use for an active gift");

        // for testing purposes the time was set to 60 minutes, but in real life application should be 48 hours.
        uint256 expireDate = block.timestamp + 60 minutes;

        gifts[hashedToken] = Gift({
            sender: payable(msg.sender),
            claimer: payable(address(0)),
            creationDate: block.timestamp,
            amount: msg.value,
            redeemed: false,
            refunded: false
        });

        emit GiftCreated(msg.sender, msg.value, hashedToken, expireDate);


    }
    function refundGift(bytes32 hashedToken) external payable {
        require(hashedToken.length > 0, "Your token cannot be empty...");
        Gift storage gift = gifts[hashedToken];
        require(
            gift.sender != address(0),
            "Gift doesn't exist."
        );
        require(
            gift.sender == msg.sender,
            "Only the creator can refund this gift."
        );
        require(
            !gift.redeemed,
            "The gift has been already redeemed."
        );
        require(
            !gift.refunded,
            "The gift has been already refunded."
        );
        require(
            block.timestamp > gift.creationDate + 60 minutes,
            "The gift hasn't expired yet."
        );
        gift.refunded = true;
        (bool success,) = gift.sender.call{value: gift.amount}("");
        require(success, "Something happened while trying to refund this gift.");
        
        emit GiftRefunded(msg.sender, gift.amount, hashedToken);

    }
}