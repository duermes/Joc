// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.10.0;

contract contractRedLetter {
    /* Variables */
    address public owner;
    uint256 public giftExpirationTime; // En segundos

    /* Structs */
    struct Gift {
        address payable sender;
        address payable claimer;
        uint256 creationDate;
        uint256 amount;
        bool redeemed;
        bool refunded;
    }

    /* Mappings & Events */
    mapping(bytes32 => Gift) public gifts;

    event GiftCreated(
        address indexed from,
        uint256 amount,
        bytes32 indexed giftId,
        uint256 expireDate
    );
    event GiftRedeemed(
        address indexed to,
        uint256 amount,
        bytes32 indexed giftId
    );
    event GiftRefunded(
        address indexed from,
        uint256 amount,
        bytes32 indexed giftId
    );

    /* Modifiers */
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function."
        );
        _;
    }

    /**
     * @notice Constructor para inicializar el contrato.
     * @param _expirationTimeInSeconds El tiempo en segundos que un regalo debe esperar antes de poder ser reembolsado.
     *                                 Ejemplo: para 48 horas, pasar 172800 (48 * 60 * 60).
     */
    constructor(uint256 _expirationTimeInSeconds) {
        require(
            _expirationTimeInSeconds > 0,
            "Expiration time must be greater than zero."
        );
        owner = msg.sender; // La persona que despliega el contrato se convierte en el dueño.
        giftExpirationTime = _expirationTimeInSeconds;
    }

    function claimGift(bytes32 hashedToken) external payable {
        require(
            hashedToken.length > 0,
            "WHAT DID WE SAY ABOUT EMPTY TOKENS, you can't claim anything without one"
        );
        Gift storage gift = gifts[hashedToken];
        require(gift.sender != address(0), "This gift doesn't exist!");
        require(!gift.redeemed, "Gift already claimed.");
        require(
            !gift.refunded,
            "This gift has already been refunded and is no longer available."
        );

        gift.redeemed = true;
        gift.claimer = payable(msg.sender);

        (bool success, ) = msg.sender.call{value: gift.amount}("");
        require(
            success,
            "An error has occurred and you couldn't claim the gift"
        );
        emit GiftRedeemed(msg.sender, gift.amount, hashedToken);
    }

    function createGift(bytes32 hashedToken) external payable {
        require(msg.value > 0, "Why are you trying to send an empty gift?");
        require(
            hashedToken.length > 0,
            "Secret phrase cannot be empty! You sure wanna do this without one?..."
        );
        Gift storage existingGift = gifts[hashedToken];
        require(
            existingGift.sender == address(0) ||
                existingGift.redeemed ||
                existingGift.refunded,
            "Secret phrase already in use for an active gift"
        );

        uint256 expireDate = block.timestamp + giftExpirationTime;

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

    function refundGift(bytes32 hashedToken) external {
        // No necesita ser payable
        require(hashedToken.length > 0, "Your token cannot be empty...");
        Gift storage gift = gifts[hashedToken];
        require(gift.sender != address(0), "Gift doesn't exist.");
        require(
            gift.sender == msg.sender,
            "Only the creator can refund this gift."
        );
        require(!gift.redeemed, "The gift has been already redeemed.");
        require(!gift.refunded, "The gift has been already refunded.");
        require(
            block.timestamp > gift.creationDate + giftExpirationTime,
            "The gift hasn't expired yet."
        );

        gift.refunded = true;
        (bool success, ) = gift.sender.call{value: gift.amount}("");
        require(
            success,
            "Something happened while trying to refund this gift."
        );

        emit GiftRefunded(msg.sender, gift.amount, hashedToken);
    }

    /**
     * @notice Permite al dueño del contrato cambiar el tiempo de expiración.
     */
    function setExpirationTime(
        uint256 _newExpirationTimeInSeconds
    ) external onlyOwner {
        require(
            _newExpirationTimeInSeconds > 0,
            "Expiration time must be greater than zero."
        );
        giftExpirationTime = _newExpirationTimeInSeconds;
    }
}
