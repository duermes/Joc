pragma solidity ^0.8.0;

contract GiftCard {
    struct Gift {
        address sender;
        uint256 amount;
        bool redeemed;
    }

    // Each recipient can have multiple gift cards
    mapping(address => Gift[]) public gifts;

    event GiftCreated(address indexed sender, address indexed recipient, uint256 amount, uint256 giftId);
    event GiftRedeemed(address indexed recipient, uint256 amount, uint256 giftId);

    /// @notice Send Ether as a gift to a recipient
    function sendGift(address recipient) external payable {
        require(msg.value > 0, "Gift amount must be greater than 0");
        require(recipient != address(0), "Invalid recipient address");

        gifts[recipient].push(Gift({
            sender: msg.sender,
            amount: msg.value,
            redeemed: false
        }));

        uint256 giftId = gifts[recipient].length - 1;
        emit GiftCreated(msg.sender, recipient, msg.value, giftId);
    }

    /// @notice Redeem a specific gift by its index
    function redeemGift(uint256 giftId) external {
        require(giftId < gifts[msg.sender].length, "Gift does not exist");

        Gift storage gift = gifts[msg.sender][giftId];
        require(!gift.redeemed, "Gift already redeemed");
        require(gift.amount > 0, "Gift amount must be positive");

        gift.redeemed = true;
        payable(msg.sender).transfer(gift.amount);

        emit GiftRedeemed(msg.sender, gift.amount, giftId);
    }

    /// @notice Get number of gift cards available for a user
    function getGiftCount(address user) external view returns (uint256) {
        return gifts[user].length;
    }

    /// @notice View a specific gift card
    function viewGift(address user, uint256 giftId) external view returns (
        address sender, uint256 amount, bool redeemed
    ) {
        require(giftId < gifts[user].length, "Gift does not exist");
        Gift storage gift = gifts[user][giftId];
        return (gift.sender, gift.amount, gift.redeemed);
    }
}