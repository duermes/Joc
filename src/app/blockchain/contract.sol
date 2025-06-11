// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title CryptoChequeV2
 * @dev A contract that allows creating "cheques" claimable with a secret.
 * The cheque ID is the hash of the secret phrase.
 */
contract CryptoChequeV2 {
    // --- Constants for Expiry Durations (in seconds) ---
    uint256 public constant DEFAULT_EXPIRY_DURATION_SECONDS = 7 days; // 7 * 24 * 60 * 60
    uint256 public constant MIN_EXPIRY_DURATION_SECONDS = 5 minutes; // 5 * 60
    uint256 public constant MAX_EXPIRY_DURATION_SECONDS = 14 days; // 14 * 24 * 60 * 60

    // --- Struct to store Cheque details ---
    struct Cheque {
        address payable creator; // Address of the person who created the cheque
        uint256 amount; // Amount of Ether locked in the cheque
        uint256 expiryTimestamp; // Timestamp after which the cheque expires
        bool claimed; // Has the cheque been claimed?
        address payable claimant; // Who claimed the cheque (if claimed)
        bool refunded; // Has the cheque been refunded to the creator?
    }

    // --- Mappings ---
    // Mapping from a secret hash (cheque ID) to the Cheque struct
    mapping(bytes32 => Cheque) public cheques;

    // --- Events ---
    event ChequeCreated(
        bytes32 indexed chequeId,
        address indexed creator,
        uint256 amount,
        uint256 expiryTimestamp,
        string secretPhrasePreview // For off-chain tracking, DO NOT RELY ON THIS FOR SECURITY
    );

    event ChequeClaimed(
        bytes32 indexed chequeId,
        address indexed claimant,
        uint256 amount
    );

    event ChequeRefunded(
        // Funds returned to creator due to expiry or cancellation
        bytes32 indexed chequeId,
        address indexed creator,
        uint256 amount
    );

    // --- Modifiers ---
    modifier onlyExistingCheque(bytes32 _chequeId) {
        require(
            cheques[_chequeId].creator != address(0),
            "CryptoChequeV2: Cheque does not exist"
        );
        _;
    }

    // --- Functions ---

    /**
     * @dev Creates a new cheque. The sender must send Ether along with this transaction.
     * The secret phrase is used to generate a unique ID for the cheque.
     * @param _secretPhrase The secret phrase required to claim the cheque. This MUST be kept secret by the creator
     *                      and shared securely with the intended recipient.
     * @param _customExpiryDurationSeconds Optional: Custom duration in seconds from now until the cheque expires.
     *                                     If 0, DEFAULT_EXPIRY_DURATION_SECONDS is used.
     *                                     Must be between MIN_EXPIRY_DURATION_SECONDS and MAX_EXPIRY_DURATION_SECONDS if provided.
     */
    function createCheque(
        string memory _secretPhrase,
        uint256 _customExpiryDurationSeconds
    ) public payable {
        // Validate input amount
        require(msg.value > 0, "CryptoChequeV2: Amount must be greater than 0");
        // Validate secret phrase
        require(
            bytes(_secretPhrase).length > 0,
            "CryptoChequeV2: Secret phrase cannot be empty"
        );

        // Determine expiry duration
        uint256 expiryDuration;
        if (_customExpiryDurationSeconds == 0) {
            expiryDuration = DEFAULT_EXPIRY_DURATION_SECONDS;
        } else {
            require(
                _customExpiryDurationSeconds >= MIN_EXPIRY_DURATION_SECONDS &&
                    _customExpiryDurationSeconds <= MAX_EXPIRY_DURATION_SECONDS,
                "CryptoChequeV2: Custom expiry duration out of allowed range"
            );
            expiryDuration = _customExpiryDurationSeconds;
        }

        uint256 expiryTimestamp = block.timestamp + expiryDuration;

        // Generate chequeId from the secret phrase.
        // It's crucial that the _secretPhrase is unique for active cheques.
        bytes32 chequeId = keccak256(abi.encodePacked(_secretPhrase));

        // Ensure this secret (chequeId) hasn't been used for an active, non-refunded, non-claimed cheque
        Cheque storage existingCheque = cheques[chequeId];
        require(
            existingCheque.creator == address(0) ||
                existingCheque.claimed ||
                existingCheque.refunded,
            "CryptoChequeV2: Secret phrase already in use for an active cheque"
        );

        // Store the new cheque
        cheques[chequeId] = Cheque({
            creator: payable(msg.sender),
            amount: msg.value,
            expiryTimestamp: expiryTimestamp,
            claimed: false,
            claimant: payable(address(0)),
            refunded: false
        });

        // For event logging, a preview might be useful but remember the full secret is sensitive.
        // Be careful with what you log from _secretPhrase if it's very long or contains sensitive patterns.
        // Here, we just log a small part for demonstration.
        string memory preview = "starts_with_first_5_chars_only"; // Placeholder
        // A better preview might be: bytes(_secretPhrase).length > 5 ? string(abi.encodePacked(bytes(_secretPhrase)[0], ...)) : _secretPhrase;
        // However, Solidity string manipulation is cumbersome. Off-chain systems can handle this.

        emit ChequeCreated(
            chequeId,
            msg.sender,
            msg.value,
            expiryTimestamp,
            preview
        );
    }

    /**
     * @dev Allows anyone who knows the secret phrase to claim the Ether.
     * @param _secretPhrase The secret phrase for the cheque.
     */
    function claimCheque(string memory _secretPhrase) public {
        require(
            bytes(_secretPhrase).length > 0,
            "CryptoChequeV2: Secret phrase cannot be empty"
        );

        bytes32 chequeId = keccak256(abi.encodePacked(_secretPhrase));
        Cheque storage cheque = cheques[chequeId]; // Use 'storage' as we will modify it

        // Validations
        require(
            cheque.creator != address(0),
            "CryptoChequeV2: Cheque does not exist"
        );
        require(!cheque.claimed, "CryptoChequeV2: Cheque already claimed");
        require(!cheque.refunded, "CryptoChequeV2: Cheque has been refunded");
        require(
            block.timestamp <= cheque.expiryTimestamp,
            "CryptoChequeV2: Cheque has expired"
        );

        // Update cheque state
        cheque.claimed = true;
        cheque.claimant = payable(msg.sender);
        uint256 amountToClaim = cheque.amount; // Store amount before it could be zeroed (though we don't zero it here)

        // Emit event
        emit ChequeClaimed(chequeId, msg.sender, amountToClaim);

        // Securely transfer Ether to the claimant
        (bool success, ) = msg.sender.call{value: amountToClaim}("");
        require(success, "CryptoChequeV2: Ether transfer to claimant failed");
    }

    /**
     * @dev Allows the creator to get a refund if the cheque is expired and not claimed.
     * This function needs to be CALLED by the creator (or a designated party if designed differently).
     * It's not "automatic" in the sense the contract acts on its own.
     * @param _secretPhrase The secret phrase for the cheque.
     */
    function refundExpiredCheque(string memory _secretPhrase) public {
        require(
            bytes(_secretPhrase).length > 0,
            "CryptoChequeV2: Secret phrase cannot be empty"
        );

        bytes32 chequeId = keccak256(abi.encodePacked(_secretPhrase));
        Cheque storage cheque = cheques[chequeId];

        // Validations
        require(
            cheque.creator != address(0),
            "CryptoChequeV2: Cheque does not exist"
        );
        require(
            cheque.creator == msg.sender,
            "CryptoChequeV2: Only the creator can refund this cheque"
        );
        require(
            !cheque.claimed,
            "CryptoChequeV2: Cheque has already been claimed"
        );
        require(
            !cheque.refunded,
            "CryptoChequeV2: Cheque has already been refunded"
        );
        require(
            block.timestamp > cheque.expiryTimestamp,
            "CryptoChequeV2: Cheque has not expired yet"
        );

        // Update cheque state
        cheque.refunded = true;
        uint256 amountToRefund = cheque.amount;

        // Emit event
        emit ChequeRefunded(chequeId, msg.sender, amountToRefund);

        // Securely transfer Ether back to the creator
        (bool success, ) = cheque.creator.call{value: amountToRefund}("");
        require(success, "CryptoChequeV2: Ether refund to creator failed");
    }

    /**
     * @dev Allows the creator to cancel an *unclaimed* and *unexpired* cheque and get a refund.
     * This is for cases where the creator wants to revoke the cheque before it expires.
     * @param _secretPhrase The secret phrase for the cheque.
     */
    function cancelChequeByCreator(string memory _secretPhrase) public {
        require(
            bytes(_secretPhrase).length > 0,
            "CryptoChequeV2: Secret phrase cannot be empty"
        );

        bytes32 chequeId = keccak256(abi.encodePacked(_secretPhrase));
        Cheque storage cheque = cheques[chequeId];

        // Validations
        require(
            cheque.creator != address(0),
            "CryptoChequeV2: Cheque does not exist"
        );
        require(
            cheque.creator == msg.sender,
            "CryptoChequeV2: Only the creator can cancel this cheque"
        );
        require(
            !cheque.claimed,
            "CryptoChequeV2: Cheque has already been claimed"
        );
        require(
            !cheque.refunded,
            "CryptoChequeV2: Cheque has already been refunded/cancelled"
        );
        // Optional: require(block.timestamp <= cheque.expiryTimestamp, "CryptoChequeV2: Cheque expired, use refundExpiredCheque");
        // For simplicity, this function can also handle expired ones if called by creator and not claimed/refunded.
        // However, `refundExpiredCheque` is more specific for the "expired" case.

        // Update cheque state
        cheque.refunded = true; // Mark as refunded (or could have a separate 'cancelled' flag)
        uint256 amountToRefund = cheque.amount;

        // Emit event (can reuse ChequeRefunded or create ChequeCancelled)
        emit ChequeRefunded(chequeId, msg.sender, amountToRefund); // Reusing event for simplicity

        // Securely transfer Ether back to the creator
        (bool success, ) = cheque.creator.call{value: amountToRefund}("");
        require(success, "CryptoChequeV2: Ether refund to creator failed");
    }

    /**
     * @dev Get details of a cheque using its secret phrase.
     * Note: This means the caller must know the secret phrase to view details.
     * It's not recommended to make secrets queryable directly for security reasons.
     * This function is more for demonstration or if the caller *is* the creator/intended recipient.
     */
    function getChequeDetailsBySecret(
        string memory _secretPhrase
    )
        public
        view
        returns (
            address creator,
            uint256 amount,
            uint256 expiryTimestamp,
            bool claimed,
            address claimant,
            bool refunded
        )
    {
        require(
            bytes(_secretPhrase).length > 0,
            "CryptoChequeV2: Secret phrase cannot be empty for lookup"
        );
        bytes32 chequeId = keccak256(abi.encodePacked(_secretPhrase));
        Cheque memory c = cheques[chequeId];

        // Check if cheque exists by verifying if creator is not the zero address
        if (c.creator == address(0)) {
            // Return empty/default values or revert
            // For simplicity, we just return the struct values which will be default if not found
        }
        return (
            c.creator,
            c.amount,
            c.expiryTimestamp,
            c.claimed,
            c.claimant,
            c.refunded
        );
    }

    /**
     * @dev Get details of a cheque using its ID (hash of the secret).
     * This is safer if the ID is known/logged and you don't want to expose the secret to the function call.
     */
    function getChequeDetailsById(
        bytes32 _chequeId
    )
        public
        view
        onlyExistingCheque(_chequeId) // Ensures cheque exists
        returns (
            address creator,
            uint256 amount,
            uint256 expiryTimestamp,
            bool claimed,
            address claimant,
            bool refunded
        )
    {
        Cheque memory c = cheques[_chequeId];
        return (
            c.creator,
            c.amount,
            c.expiryTimestamp,
            c.claimed,
            c.claimant,
            c.refunded
        );
    }

    // Fallback functions to allow the contract to receive Ether directly
    // (though createCheque is the primary way Ether is intended to be sent to this contract)
    receive() external payable {}
    fallback() external payable {}
}
